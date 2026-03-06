import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Email & Password Sign Up
  // Handles PigeonUserDetails type cast bug in firebase_auth 4.x
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    User? user;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // PigeonUserDetails type cast error - account IS created despite this error
      print('⚠️ Signup Pigeon error (account likely created): $e');
      // Wait a moment for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));
      user = _auth.currentUser;
      if (user == null) {
        // Try signing in since account was likely created
        try {
          UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          user = cred.user;
        } catch (signInError) {
          print('❌ Recovery sign-in also failed: $signInError');
          throw 'Account creation failed: $e';
        }
      }
    }

    if (user == null) throw 'Account creation failed - no user returned';

    // Update user profile
    try {
      await user.updateDisplayName(displayName);
    } catch (e) {
      print('⚠️ updateDisplayName error (non-fatal): $e');
    }

    // Create user document in Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'authMethod': 'email',
      'isEmailVerified': false,
    });

    return user;
  }

  // Email & Password Sign In
  // Also handles PigeonUserDetails type cast bug
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // PigeonUserDetails type cast error - sign in actually succeeded
      print('⚠️ SignIn Pigeon error (sign-in likely succeeded): $e');
      await Future.delayed(const Duration(milliseconds: 500));
      if (_auth.currentUser != null) {
        return null; // Sign in succeeded despite the error
      }
      throw 'Sign in failed: $e';
    }
  }

  // Send OTP to email via Flask backend
  /// Generates a 6-digit OTP code and stores it in Firestore.
  /// Calls Flask backend to send OTP via Gmail.
  /// 
  /// OTP is valid for 10 minutes. User must verify before account creation.
  /// For Gmail users (Google Sign-In), no OTP is required.
  Future<void> sendOTP({required String email}) async {
    try {
      // Generate OTP
      String otp = _generateOTP();

      // Store OTP in Firestore with expiration (10 minutes)
      await _firestore.collection('otp_codes').doc(email).set({
        'code': otp,
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
        'email': email,
        'verified': false,
      }, SetOptions(merge: true));

      // Send OTP via Flask backend
      // IMPORTANT: Replace IP with your machine IP for local testing
      // OR with Vercel URL for production
      final String backendUrl = AppConfig.backendUrl;

      try {
        print('📧 Sending OTP to Flask: $backendUrl/send-otp');
        print('📧 Email: $email, OTP: $otp');

        final response = await http.post(
          Uri.parse('$backendUrl/send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'otp': otp,
          }),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw 'Email service timeout. Flask server not responding.',
        );

        print('📧 Response status: ${response.statusCode}');
        print('📧 Response body: ${response.body}');

        if (response.statusCode == 200) {
          print('✅ OTP sent successfully to $email');
        } else {
          throw 'Server error: ${response.statusCode} - ${response.body}';
        }
      } catch (httpError) {
        print('❌ HTTP Error sending OTP: $httpError');
        print('❌ Is Flask running on $backendUrl?');
        throw 'Failed to send OTP email. Flask server error: $httpError';
      }
    } catch (e) {
      print('❌ Error sending OTP: $e');
      throw 'Failed to send OTP: $e';
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('otp_codes').doc(email).get();

      if (!doc.exists) {
        throw 'OTP not found';
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String storedOTP = data['code'];
      DateTime expiresAt = (data['expiresAt'] as Timestamp).toDate();

      // Check if OTP is expired
      if (DateTime.now().isAfter(expiresAt)) {
        throw 'OTP has expired';
      }

      // Check if OTP matches
      if (storedOTP != otp) {
        throw 'Invalid OTP';
      }

      // Mark OTP as verified
      await _firestore.collection('otp_codes').doc(email).update({
        'verified': true,
        'verifiedAt': DateTime.now(),
      });

      return true;
    } catch (e) {
      throw 'OTP verification failed: $e';
    }
  }

  // Google Sign In — handles PigeonUserDetails type cast bug in firebase_auth 4.x
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential? userCredential;
      try {
        userCredential = await _auth.signInWithCredential(credential);
      } catch (e) {
        // PigeonUserDetails type cast error — sign-in actually succeeded
        print('⚠️ Google SignIn Pigeon error (sign-in likely succeeded): $e');
        await Future.delayed(const Duration(milliseconds: 500));
        if (_auth.currentUser == null) {
          throw 'Google sign in failed';
        }
      }

      final user = userCredential?.user ?? _auth.currentUser;
      if (user == null) throw 'Google sign in failed — no user returned';

      // Check if user document exists, if not create it
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
            'authMethod': 'google',
            'isEmailVerified': user.emailVerified,
          });
        } else {
          await _firestore.collection('users').doc(user.uid).update({
            'updatedAt': DateTime.now(),
            'lastLogin': DateTime.now(),
          });
        }
      } catch (e) {
        print('⚠️ Firestore user doc update error (non-fatal): $e');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Check if sign-in actually succeeded despite the error
      if (_auth.currentUser != null) {
        return null; // Success despite Pigeon error
      }
      throw 'Google sign in failed: $e';
    }
  }

  // Google Sign Up (same as sign in for Google)
  Future<UserCredential?> signUpWithGoogle() async {
    return signInWithGoogle();
  }

  // Password Reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  // Helper method to generate OTP
  String _generateOTP() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString()
        .substring(0, 6);
  }

  // Handle authentication exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw 'Failed to get user data: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }
}
