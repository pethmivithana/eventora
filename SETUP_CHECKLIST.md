# Eventora Setup Checklist

Use this checklist to ensure everything is set up correctly before running the app.

## ✅ Pre-Setup Requirements

- [ ] Flutter SDK installed (v3.5.0+) - Run `flutter --version`
- [ ] Dart SDK installed - Run `dart --version`
- [ ] Android Studio or Xcode installed
- [ ] Git installed
- [ ] GitHub account access to pethmivithana/eventora
- [ ] Firebase account (free tier is fine)
- [ ] Android Emulator running OR physical device connected

---

## ✅ Step 1: Repository Setup

- [ ] Repository cloned to your machine
  ```bash
  git clone https://github.com/pethmivithana/eventora.git
  cd eventora
  ```
- [ ] On the `main` branch or `fix-library-code` branch
  ```bash
  git branch -a
  git checkout main
  ```
- [ ] No uncommitted changes
  ```bash
  git status
  ```

---

## ✅ Step 2: Dependencies Installation

- [ ] All Flutter dependencies installed
  ```bash
  flutter pub get
  ```
- [ ] Project cleaned (if fresh install)
  ```bash
  flutter clean
  flutter pub get
  ```
- [ ] No dependency version conflicts (check output for warnings)

**Expected packages:**
- ✅ firebase_core, firebase_auth
- ✅ cloud_firestore
- ✅ flutter_riverpod
- ✅ go_router
- ✅ flutter_animate, shimmer
- ✅ uuid, intl
- ✅ And all others in pubspec.yaml

---

## ✅ Step 3: Firebase Project Creation

- [ ] Firebase Project created at firebase.google.com
  - Project name: `eventora` (or similar)
  - Google Analytics: Optional
  
- [ ] **Authentication Enabled**:
  - [ ] Go to: Firebase Console → Authentication → Sign-in method
  - [ ] Enable: **Email/Password**
  - [ ] Enable: **Google** (optional)

- [ ] **Firestore Database Created**:
  - [ ] Go to: Firebase Console → Firestore Database
  - [ ] Click: **Create Database**
  - [ ] Select: **Production mode** (Firestore Rules will be set later)
  - [ ] Select: **Region** (US-Central or your region)
  
- [ ] **Firestore Rules Set** (Development Rules):
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.auth != null;
      }
    }
  }
  ```
  - In Firebase Console → Firestore → Rules tab

---

## ✅ Step 4: Android Configuration

- [ ] Android package name identified:
  - Open: `android/app/build.gradle`
  - Find: `applicationId "com.example.eventora"` (or your custom package)
  - Note it down

- [ ] Android app added to Firebase:
  - [ ] Firebase Console → **+ Add app** → **Android**
  - [ ] Enter package name: `com.example.eventora`
  - [ ] Download `google-services.json`
  
- [ ] `google-services.json` placed correctly:
  - [ ] File location: `android/app/google-services.json`
  - [ ] File exists and is not empty
  - [ ] Contains your Firebase credentials

- [ ] Android Gradle plugins configured:
  - [ ] `android/build.gradle` has Google Services plugin:
    ```gradle
    classpath 'com.google.gms:google-services:4.3.15'
    ```
  - [ ] `android/app/build.gradle` has at bottom:
    ```gradle
    apply plugin: 'com.google.gms.google-services'
    ```

---

## ✅ Step 5: iOS Configuration (Optional - for iOS builds)

- [ ] iOS Bundle ID identified:
  - Open Xcode: `open ios/Runner.xcworkspace`
  - Check: Runner → Build Settings → Bundle Identifier
  - Typically: `com.example.eventora`

- [ ] iOS app added to Firebase:
  - [ ] Firebase Console → **+ Add app** → **iOS**
  - [ ] Enter Bundle ID: `com.example.eventora`
  - [ ] Download `GoogleService-Info.plist`

- [ ] `GoogleService-Info.plist` placed correctly:
  - [ ] File location: `ios/Runner/GoogleService-Info.plist`
  - [ ] In Xcode: Drag file into Runner project
  - [ ] Check "Copy if needed" in Xcode dialog

---

## ✅ Step 6: Firebase Configuration in Code

Choose ONE method:

### Option A: Automatic Configuration (RECOMMENDED)
- [ ] FlutterFire CLI installed:
  ```bash
  flutter pub global activate flutterfire_cli
  ```
- [ ] Configuration run:
  ```bash
  flutterfire configure
  ```
- [ ] File updated: `lib/firebase_options.dart` has real values
- [ ] No errors in output

### Option B: Manual Configuration
- [ ] Firebase Console opened → Project Settings → Your Apps
- [ ] Credentials copied for Android
- [ ] `lib/firebase_options.dart` updated:
  ```dart
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',           // From Firebase
    appId: '1:123456789:android:abc', // From Firebase
    messagingSenderId: '123456789',   // From Firebase
    projectId: 'eventora-xxxxx',      // From Firebase
    storageBucket: 'eventora-xxxxx.appspot.com', // From Firebase
  );
  ```
- [ ] File saved and verified

---

## ✅ Step 7: Device/Emulator Setup

### For Android Emulator:
- [ ] Android Emulator running:
  ```bash
  flutter emulators
  # If not running, start one:
  flutter emulators launch <emulator_name>
  ```
- [ ] Device visible:
  ```bash
  flutter devices
  ```
- [ ] Shows: `emulator-5554` or similar

### For Physical Android Device:
- [ ] USB Debugging enabled
  - Settings → Developer Options → USB Debugging: ON
- [ ] Connected via USB
- [ ] Device visible:
  ```bash
  flutter devices
  ```
- [ ] Shows device name

### For iOS Simulator:
- [ ] Simulator running:
  ```bash
  open -a Simulator
  ```
- [ ] Device visible:
  ```bash
  flutter devices
  ```

---

## ✅ Step 8: Code Verification

- [ ] `lib/main.dart` exists and is valid
  - No import errors
  - Initializes Firebase correctly

- [ ] `lib/firebase_options.dart` has real values
  - NOT placeholder values like `YOUR_API_KEY`
  - Contains actual Firebase project credentials

- [ ] All lib files compile without errors:
  ```bash
  flutter analyze
  ```
  - Should show: `No issues found!` or minor warnings only

---

## ✅ Step 9: Ready to Run!

Before running, do final check:

```bash
# Clean and fresh install
flutter clean
flutter pub get

# Verify everything builds
flutter run --dry-run
```

Expected output:
- ✅ No dependency errors
- ✅ Dart analysis passes
- ✅ Build succeeds
- ✅ Device is detected

**If all above are green**, you're ready!

---

## ✅ Step 10: Run the App

### Quick Run:
```bash
flutter run
```

### Or use the quick-start script:
```bash
chmod +x QUICK_START.sh
./QUICK_START.sh
```

---

## ✅ Step 11: Verify App Works

Once app starts:

1. [ ] **Splash Screen** appears for 2 seconds
2. [ ] **Login Screen** loads without errors
3. [ ] **Sign Up button** works
4. [ ] Create test account:
   - Email: `test@example.com`
   - Password: `Test123!`
5. [ ] **Login** works with test account
6. [ ] **Home Screen** loads (may be empty for new account)
7. [ ] **Floating Action Button** visible to create event
8. [ ] **Bottom Navigation** shows Profile icon
9. [ ] **Profile Screen** accessible
10. [ ] **Logout** works and returns to Login Screen

---

## ⚠️ Troubleshooting

If any step fails, refer to `SETUP_AND_RUN.md` for detailed troubleshooting.

**Common issues:**
- Firebase not configured → See Step 4-6
- google-services.json missing → Download from Firebase
- Gradle build fails → Run `flutter clean` and `flutter pub get`
- Pod install fails → Run `cd ios && pod install && cd ..`
- App crashes → Check `flutter logs` output

---

## 📝 Notes

- Keep `google-services.json` and `GoogleService-Info.plist` secure (don't commit to public repos)
- Initial Firestore rules are for development only - secure before production
- All dependencies are compatible with Flutter 3.5.0+

---

## ✅ All Complete!

Once you've checked all boxes above, your Eventora app is ready to run perfectly!

For questions or issues, see `SETUP_AND_RUN.md` or GitHub Issues.

Happy coding! 🚀
