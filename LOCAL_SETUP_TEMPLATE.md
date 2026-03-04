# Local Setup Template - DO NOT COMMIT
# Files in this directory should NEVER be pushed to GitHub
# Each team member configures these locally

## Setup Instructions for Team Members

### Step 1: Get Your Firebase Config Files

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select the project
3. Download files:
   - **Android**: Project Settings → Android App → Download `google-services.json`
   - **iOS**: Project Settings → iOS App → Download `GoogleService-Info.plist`

### Step 2: Place Files in Correct Locations

After downloading, place them in:
```
android/app/google-services.json         ← From Firebase Console
ios/Runner/GoogleService-Info.plist      ← From Firebase Console
lib/firebase_options.dart                ← From Firebase Console
```

### Step 3: Verify They're In .gitignore

Run this to verify they won't be committed:
```bash
git status
```

These files should NOT appear in the output.

### Step 4: Configure App Package Name

**Android:**
- Edit `android/app/build.gradle`
- Find: `namespace = "com.example.quiz_app"`
- Replace with your actual package name (from Firebase)

**iOS:**
- Edit `ios/Runner.xcodeproj/project.pbxproj`
- Ensure Bundle ID matches Firebase iOS setup

### Step 5: Test

```bash
flutter clean
flutter pub get
flutter run
```

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
