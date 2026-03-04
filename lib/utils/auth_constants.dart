// Constants and configuration for authentication

class AuthConstants {
  // OTP Settings
  static const int otpLength = 6;
  static const int otpExpirationMinutes = 10;
  static const int otpResendDelaySeconds = 30;

  // Password Requirements
  static const int minPasswordLength = 8;
  static const bool requireUppercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = false;

  // Error Messages
  static const String invalidEmail = 'Please enter a valid email address';
  static const String weakPassword =
      'Password must be at least $minPasswordLength characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String emptyFields = 'Please fill all required fields';
  static const String agreeToTerms =
      'Please agree to terms and conditions';
  static const String invalidOTP = 'Invalid or expired OTP';
  static const String networkError = 'Network error. Please try again';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String otpCodesCollection = 'otp_codes';
}

class ValidationHelper {
  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate password strength
  static bool isPasswordStrong(String password) {
    if (password.length < AuthConstants.minPasswordLength) return false;

    if (AuthConstants.requireUppercase &&
        !password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    if (AuthConstants.requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    if (AuthConstants.requireSpecialChars &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }

  // Get password strength message
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < AuthConstants.minPasswordLength) {
      return 'At least ${AuthConstants.minPasswordLength} characters required';
    }
    if (AuthConstants.requireUppercase &&
        !password.contains(RegExp(r'[A-Z]'))) {
      return 'Add an uppercase letter';
    }
    if (AuthConstants.requireNumbers && !password.contains(RegExp(r'[0-9]'))) {
      return 'Add a number';
    }
    return 'Strong password';
  }

  // Validate display name
  static bool isValidDisplayName(String name) {
    return name.trim().isNotEmpty && name.length >= 2;
  }
}
