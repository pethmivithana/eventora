# Eventora - Complete Setup & Run Guide

## 🎯 Overview
This is a Flutter event management app with Firebase backend. All library code has been fixed and is ready to run.

---

## 📋 What Was Fixed

### 1. **pubspec.yaml** - Added All Missing Dependencies
✅ Flutter Riverpod (state management)
✅ GoRouter (navigation)
✅ Firebase packages
✅ Flutter Animate (animations)
✅ Flutter Slidable (list animations)
✅ Shimmer (loading effects)
✅ Connectivity Plus (offline detection)
✅ Google Fonts, UUID, Intl utilities

### 2. **lib/firebase_options.dart** - Updated with Clear Instructions
- Replaced placeholder comments with detailed setup instructions
- Added step-by-step guide to configure Firebase
- Included both Android and iOS configurations
- Ready for automatic Firebase CLI setup

### 3. **lib/data/services/auth_service.dart** - Fixed Imports
- Corrected UserModel import path
- All references now point to correct models

---

## 🚀 Step-by-Step Setup

### Step 1: Install Flutter (if not already installed)
```bash
# Download from: https://flutter.dev/docs/get-started/install
# Or use Homebrew on Mac:
brew install flutter

# Verify installation:
flutter --version
flutter doctor
```

### Step 2: Clone & Enter Project
```bash
cd ~/your/projects/directory
git clone https://github.com/pethmivithana/eventora.git
cd eventora
```

### Step 3: Get Dependencies
```bash
flutter pub get
```

### Step 4: Setup Firebase (REQUIRED)

#### Option A: Automatic Setup (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase automatically
flutterfire configure

# Follow the prompts:
# 1. Select your Firebase project (or create new)
# 2. Select platforms: Android and iOS
# 3. The tool will auto-generate firebase_options.dart
```

#### Option B: Manual Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "eventora"
3. Add Android app:
   - Package name: `com.example.eventora`
   - Get the config from Firebase Console
4. Add iOS app:
   - Bundle ID: `com.example.eventora`
   - Get the config from Firebase Console
5. Copy the credentials to `lib/firebase_options.dart`

### Step 5: Run on Device/Emulator

#### Start Android Emulator
```bash
emulator -list-avds  # List available emulators
emulator -avd Pixel_4_API_30  # Start specific emulator
```

#### Start iOS Simulator
```bash
open -a Simulator  # Or from Xcode
```

#### Run the App
```bash
flutter run

# Or specify target:
flutter run -d emulator-5554        # Android
flutter run -d iPhone14             # iOS
```

---

## 📱 Run Commands Reference

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install/update dependencies |
| `flutter run` | Run on connected device/emulator |
| `flutter run -d <device-id>` | Run on specific device |
| `flutter devices` | List connected devices |
| `flutter clean` | Clean build artifacts |
| `flutter pub upgrade` | Upgrade dependencies |
| `flutter analyze` | Analyze code for issues |
| `flutter format lib/` | Format Dart code |

---

## 🔐 Firebase Setup Details

### What You Need from Firebase Console:

**For Android:**
```
- API Key (apiKey)
- App ID (appId: 1:xxx:android:xxx)
- Sender ID (messagingSenderId)
- Project ID (projectId)
- Storage Bucket (storageBucket)
```

**For iOS:**
```
- API Key (apiKey)
- App ID (appId: 1:xxx:ios:xxx)
- Sender ID (messagingSenderId)
- Project ID (projectId)
- Storage Bucket (storageBucket)
- Bundle ID (iosBundleId)
```

### Important: Enable Firebase Features
In Firebase Console, go to:
1. **Authentication** → Enable Email/Password
2. **Firestore Database** → Create database in test mode
3. **Rules** → Update security rules (see below)

**Firestore Security Rules (for testing):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## ✅ Verification Checklist

- [ ] Flutter installed (`flutter --version`)
- [ ] Project cloned
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] Firebase configured (`flutterfire configure` completed)
- [ ] Device/Emulator running
- [ ] App runs without errors (`flutter run`)

---

## 🐛 Common Issues & Solutions

### Issue: "firebase_options.dart not found"
**Solution:** Run `flutterfire configure` to auto-generate it

### Issue: "Permission denied" on Android
**Solution:** Grant permissions in app settings or reinstall with `flutter clean && flutter pub get && flutter run`

### Issue: "Pod install" errors on iOS
**Solution:** 
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter pub get
flutter run
```

### Issue: "Dependency conflict"
**Solution:**
```bash
flutter pub upgrade
flutter clean
flutter pub get
flutter run
```

### Issue: "Device not found"
**Solution:** 
```bash
flutter devices  # Check connected devices
# Make sure emulator is running or device is connected via USB
```

---

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration ✅ FIXED
├── core/
│   ├── router/
│   │   └── app_router.dart       # Navigation setup
│   ├── theme/
│   │   └── app_theme.dart        # Theming & colors
│   └── constants/
│       └── app_constants.dart    # App-wide constants
├── data/
│   ├── models/
│   │   └── event_model.dart      # Data models (including UserModel)
│   └── services/
│       ├── auth_service.dart     # ✅ FIXED - Firebase auth
│       └── connectivity_service.dart  # Offline detection
└── presentation/
    ├── events/
    │   └── home_screen.dart      # Main event list screen
    └── auth/
        └── login_screen.dart     # Authentication screen
```

---

## 📚 Library Documentation

The app uses:
- **firebase_auth** - User authentication
- **cloud_firestore** - Database (events, users)
- **flutter_riverpod** - State management
- **go_router** - Navigation & routing
- **flutter_animate** - Animations
- **connectivity_plus** - Offline detection
- **google_fonts** - Custom typography

---

## 🎮 First Run Experience

When you run the app for the first time:

1. **Login Screen** appears
2. Create account with email/password
3. Firebase stores user in Authentication
4. App navigates to **Home Screen**
5. Create, view, and manage events
6. All data synced to Firestore

---

## 💡 Next Steps After Running

1. **Customize Firebase Rules** for production security
2. **Add Event Features:**
   - Event categories
   - Attendee management
   - Notifications
3. **Styling:** Update `app_theme.dart` with your brand colors
4. **Add More Screens:** Use Riverpod for state management

---

## 📞 Need Help?

If you encounter issues:
1. Check "Common Issues & Solutions" above
2. Run `flutter doctor` to diagnose setup issues
3. Check Firebase Console for errors
4. Run `flutter analyze` to find code issues

---

## ✨ You're All Set!

All library code is fixed and ready. Follow the steps above and your Eventora app will run perfectly! 🎉
