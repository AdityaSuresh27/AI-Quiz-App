# Local Setup Guide - Smart Quiz App

> **This file is safe to commit.** It contains no secrets — only instructions.
> All sensitive files listed below must be obtained privately from the project owner.

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter SDK | >= 3.10.1 | https://docs.flutter.dev/get-started/install |
| Dart SDK | (bundled with Flutter) | — |
| Android Studio / VS Code | Latest | — |
| Python | >= 3.9 | https://www.python.org/downloads/ |
| Git | Latest | https://git-scm.com/ |
| Firebase CLI | Latest | `npm install -g firebase-tools` |

---

## Files You Need Privately (NOT in the repo)

The following files are **gitignored** and must be obtained from the project owner.
Ask them to send these securely (not via public channels).

### 1. Firebase Configuration (Flutter app)

| File | Location | How to get |
|------|----------|------------|
| `google-services.json` | `android/app/google-services.json` | Firebase Console → Project Settings → Android app → Download |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` | Firebase Console → Project Settings → iOS app → Download |
| `firebase_options.dart` | `lib/firebase_options.dart` | Run `flutterfire configure` OR get from project owner |

### 2. Backend Environment Variables

| File | Location | How to get |
|------|----------|------------|
| `.env` | `backend/.env` | Copy `backend/.env.example` and fill in real values from project owner |

The `backend/.env` file needs:

```env
# Gmail App Password for OTP emails
SENDER_EMAIL=<gmail-address>
SENDER_PASSWORD=<16-char-app-password>

# OpenAI API Key for AI quiz generation (optional — app works without it)
OPENAI_API_KEY=sk-...
```

**To create a Gmail App Password:**
1. Enable 2-Step Verification on your Google account
2. Go to https://myaccount.google.com/apppasswords
3. Generate an App Password → copy the 16-character code

---

## Step-by-Step Setup

### 1. Clone the repo

```bash
git clone <repo-url>
cd MAP-final-project
```

### 2. Place private files

Copy the files you received into the correct locations:

```
android/app/google-services.json       ← Firebase (Android)
ios/Runner/GoogleService-Info.plist     ← Firebase (iOS)
lib/firebase_options.dart               ← Firebase (Dart config)
backend/.env                            ← Backend secrets
```

### 3. Install Flutter dependencies

```bash
flutter pub get
```

### 4. Verify setup

```bash
flutter doctor      # Check Flutter installation
flutter analyze     # Check for code issues
```

### 5. Run the Flutter app

```bash
# On a connected device or emulator
flutter run
```

### 6. Run the backend locally (optional — for OTP & AI quiz)

```bash
cd backend
pip install -r requirements.txt
python app.py
```

The Flask server starts on `http://localhost:5000` by default.

> **Note:** The app uses a deployed Vercel backend by default (configured in
> `lib/config.dart` → `AppConfig.backendUrl`). You only need to run the backend
> locally if you're developing/testing backend changes. To point the app at your
> local server, update `backendUrl` in `lib/config.dart` to your machine's IP
> (e.g. `http://192.168.x.x:5000`).

---

## Project Structure

```
├── lib/                    # Flutter app source
│   ├── main.dart           # App entry point
│   ├── config.dart         # Theme, colors, backend URL
│   ├── screens.dart        # All main screens (Home, Profile, Quiz, etc.)
│   ├── widgets.dart        # Reusable UI components
│   ├── models.dart         # Data models
│   ├── qr_screens.dart     # QR code create/scan screens
│   ├── auth/               # Login, Signup, OTP, Forgot Password screens
│   └── services/           # AuthProvider, AuthService
├── backend/                # Python Flask backend (Vercel-deployed)
│   ├── app.py              # Flask routes (send-otp, generate-quiz)
│   ├── requirements.txt    # Python dependencies
│   ├── vercel.json         # Vercel deployment config
│   ├── .env.example        # Template for backend secrets
│   └── .env                # ⛔ GITIGNORED — your real secrets
├── android/                # Android platform files
├── ios/                    # iOS platform files
└── pubspec.yaml            # Flutter dependencies
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `google-services.json` not found | Place it in `android/app/` — get from Firebase Console or project owner |
| `firebase_options.dart` missing | Run `flutterfire configure` or get from project owner |
| OTP emails not sending | Check `backend/.env` has correct `SENDER_EMAIL` and `SENDER_PASSWORD` |
| AI Quiz not working | Ensure `OPENAI_API_KEY` is set in `backend/.env` |
| Build fails on Android | Run `flutter clean && flutter pub get` then rebuild |
| Gradle errors | Check `android/local.properties` has correct SDK paths |

---

## What's Safe to Commit vs. What's NOT

| Safe to commit | NEVER commit |
|----------------|--------------|
| All `lib/*.dart` (except `firebase_options.dart`) | `google-services.json` |
| `pubspec.yaml` | `GoogleService-Info.plist` |
| `backend/app.py` | `lib/firebase_options.dart` |
| `backend/.env.example` | `backend/.env` |
| `backend/requirements.txt` | Any file with API keys or passwords |

---

## SECURITY RULES ⚠️

✅ DO:
- Download config files from Firebase Console
- Store locally (in these .gitignore directories)
- Share Firebase project access via Console (not files)

❌ DON'T:
- Commit config files to GitHub
- Share API keys via email
- Hardcode secrets in code
- Push `.env` files with credentials

---

## Troubleshooting

**"Firebase initialization error"?**
- Check that config files are in correct locations
- Verify package names match exactly
- Run `flutter clean && flutter pub get`

**"google-services.json not found"?**
- Download fresh from Firebase Console
- Place in `android/app/` directory
- Run `flutter clean`

**Can't download config files?**
- Make sure you have Firebase project Admin access
- Contact project lead for access
- Or ask them to download and send privately (not via git)
