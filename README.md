# Smart Quiz App 📚🎯

A Flutter-based quiz application with Firebase authentication, OTP email verification, Google Sign-In, and QR-based quiz sharing.

## Features

✅ **Authentication**
- Email/Password signup with OTP verification (via Flask + Gmail SMTP)
- Email/Password signin
- Google Sign-In/Sign-Up
- Password reset
- Sign-out with confirmation
- Multi-user support via Firestore

✅ **Quiz Management**
- Create custom quizzes
- QR code generation for quiz sharing
- QR code scanning to join quizzes
- Quiz analytics and detailed results
- Category-based organization

✅ **OTP Email System**
- 6-digit OTP generation
- 10-minute expiration
- Flask backend for email delivery via Gmail SMTP
- Local Flask server for development
- Vercel deployment ready

✅ **UI/UX**
- Beautiful gradient design
- Smooth navigation
- SafeArea layouts (no excessive white space)
- Responsive design across devices

## Tech Stack

**Frontend:** Flutter 3.x, Dart
**Backend:** Firebase (Auth, Firestore, Storage) + Flask (OTP emails)
**Email:** Gmail SMTP via app password (free tier)
**Deployment:** Android/iOS app + Vercel (Flask backend)

## Quick Setup (for team members)

See [LOCAL_SETUP_TEMPLATE.md](LOCAL_SETUP_TEMPLATE.md) for complete setup instructions.

**TL;DR:**
```bash
# Clone repo
git clone <repo-url>
cd MAP-final-project

# Download config files from Firebase Console
# Place: android/app/google-services.json, ios/Runner/GoogleService-Info.plist, lib/firebase_options.dart

# Create backend/.env (only for development/local testing)
echo "SENDER_EMAIL=your-email@gmail.com" > backend/.env
echo "SENDER_PASSWORD=your-16-char-app-password" >> backend/.env

# Run app
flutter clean
flutter pub get
flutter run

# Run Flask OTP server (in another terminal)
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py  # Runs on localhost:5000
```

## Project Structure

```
├── lib/
│   ├── main.dart                    # App entry point
│   ├── auth/auth_screens.dart       # Login, signup, OTP, password reset
│   ├── services/
│   │   ├── auth_service.dart        # Firebase + OTP logic
│   │   └── auth_provider.dart       # State management
│   ├── screens.dart                 # Home, categories, quiz screens
│   ├── qr_screens.dart              # QR creation and scanning
│   ├── widgets.dart                 # Reusable UI components
│   ├── config.dart                  # Theme, colors, constants
│   └── models.dart                  # Data models
├── backend/
│   ├── app.py                       # Flask OTP server
│   ├── requirements.txt             # Python dependencies
│   ├── vercel.json                  # Vercel deployment config
│   └── .env                         # Gmail credentials (LOCAL ONLY)
├── android/
│   └── app/google-services.json     # Firebase config (LOCAL ONLY)
├── ios/
│   └── Runner/GoogleService-Info.plist  # Firebase config (LOCAL ONLY)
├── lib/firebase_options.dart        # Firebase init (LOCAL ONLY)
├── .gitignore                       # Excludes secrets
├── pubspec.yaml                     # Flutter dependencies
└── LOCAL_SETUP_TEMPLATE.md          # Setup guide for team members
```

## Key Credentials (Setup Required)

⚠️ **Never commit these files to GitHub:**
- `backend/.env` (Gmail app password)
- `lib/firebase_options.dart` (Firebase API keys)
- `android/app/google-services.json` (Android config)
- `ios/Runner/GoogleService-Info.plist` (iOS config)

Each team member must:
1. Download their own config files from [Firebase Console](https://console.firebase.google.com)
2. Create their own `backend/.env` for local testing
3. These files are automatically ignored via `.gitignore`

## Authentication Flow

### Email Signup (with OTP)
```
Name, Email, Password → Send OTP → Verify OTP → Create Account → Home
```

### Email Signin
```
Email, Password → Home (no OTP needed)
```

### Google Sign-In/Up
```
Google Account → Home (no OTP needed, uses Google OAuth)
```

## OTP Email Setup

The Flask backend sends OTP emails via Gmail SMTP:

1. Use a Gmail account with **2-Step Verification** enabled
2. Generate a 16-character **App Password** at [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
3. Add to `backend/.env`:
   ```
   SENDER_EMAIL=your-email@gmail.com
   SENDER_PASSWORD=your-16-char-app-password
   ```
4. Run Flask server: `python backend/app.py`
5. App sends OTPs to registered emails within 1-3 seconds

## Firebase Configuration

1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable:
   - ✅ Firebase Auth (Email/Password & Google providers)
   - ✅ Cloud Firestore (create database)
   - ✅ Cloud Storage
3. Download config files and place locally (see [LOCAL_SETUP_TEMPLATE.md](LOCAL_SETUP_TEMPLATE.md))
4. Setup Firestore security rules (see `firestore.rules`)
5. Add team members via Firebase Console → Project Settings → Members

## Network Configuration (Android)

For local development with HTTP Flask backend:
- File: `android/app/src/main/res/xml/network_security_config.xml`
- Allows cleartext HTTP only to: `10.12.225.114` (your machine IP), `localhost`, `127.0.0.1`
- ⚠️ Production must use HTTPS (Vercel)

## Deployment

### Flask Backend → Vercel
```bash
cd backend
vercel login
vercel deploy
# Copy deployment URL and update in lib/services/auth_service.dart
```

### Flutter App → Google Play Store / Apple App Store
```bash
flutter build apk --release
flutter build ios --release
```

## Git Workflow

```bash
# Before committing
git status  # Verify no secret files appear

# Commit changes
git add .
git commit -m "feat: Your feature description"
git push origin main

# Team members pull and run local setup
git clone <repo>
# Follow LOCAL_SETUP_TEMPLATE.md
```

## Troubleshooting

**OTP not sending?**
- Check Flask is running: `http://localhost:5000` (Android: `http://10.12.225.114:5000`)
- Verify `backend/.env` has correct Gmail app password
- Check Flask console for "✅ OTP sent successfully"

**Firebase auth failing?**
- Verify config files are in correct locations
- Check Firebase Email/Password provider is enabled
- Ensure package names match between app and Firebase

**White space in auth screens?**
- Ensure you have the latest `lib/auth/auth_screens.dart`
- Run `flutter clean && flutter pub get`

**Git pushing secrets by accident?**
- Immediately revoke the API key in Firebase Console
- Run: `git filter-branch --tree-filter 'rm -f android/app/google-services.json' HEAD`
- Contact team lead to re-issue keys

## Support

For setup help, check [LOCAL_SETUP_TEMPLATE.md](LOCAL_SETUP_TEMPLATE.md) or contact the project maintainer.

---

**Last Updated:** March 5, 2026  
**Status:** Production Ready ✅
