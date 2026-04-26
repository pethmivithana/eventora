# Eventora - Complete Setup & Run Guide

## Prerequisites

Before starting, ensure you have:
- **Flutter SDK** (v3.5.0 or higher): [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Firebase Account**: [Create at firebase.google.com](https://firebase.google.com)
- **Android/iOS SDK** or Emulator setup
- **Git** installed

Verify installations:
```bash
flutter --version
dart --version
```

---

## Step 1: Clone & Install Dependencies

```bash
# Clone the repository
git clone https://github.com/pethmivithana/eventora.git
cd eventora

# Get all Flutter packages
flutter pub get

# If you encounter any issues
flutter clean
flutter pub get
```

---

## Step 2: Set Up Firebase (CRITICAL)

### 2a. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create a new project** → Name it `eventora`
3. Enable Google Analytics (optional)
4. Create the project

### 2b. Add Android App to Firebase

1. In Firebase Console, click **+ Add app** → Select **Android**
2. Enter your Android package name:
   - Default: `com.example.eventora`
   - Or check in `android/app/build.gradle` → `applicationId`
3. Download `google-services.json`
4. Place the file at: `android/app/google-services.json`

### 2c. Add iOS App to Firebase (if building for iOS)

1. In Firebase Console, click **+ Add app** → Select **iOS**
2. Enter Bundle ID:
   - Default: `com.example.eventora`
   - Or check in `ios/Runner.xcodeproj`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into Xcode (check "Copy if needed")

### 2d. Configure Firebase in Code

Option A: **Automatic (Recommended)**
```bash
# Install FlutterFire CLI
flutter pub global activate flutterfire_cli

# Run configuration
flutterfire configure
```
This automatically updates `lib/firebase_options.dart`

Option B: **Manual**
1. Go to Firebase Console → **Project Settings** → **Your Apps**
2. Copy your Android credentials
3. Update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',           // Copy from Firebase
  appId: '1:XXX:android:XXX',       // Copy from Firebase
  messagingSenderId: 'XXX',         // Copy from Firebase
  projectId: 'eventora-xxx',        // Copy from Firebase
  storageBucket: 'eventora-xxx.appspot.com',  // Copy from Firebase
);
```

### 2e: Enable Firebase Services

In Firebase Console:

1. **Authentication**:
   - Go to **Authentication** → **Sign-in method**
   - Enable: **Email/Password**
   - Enable: **Google** (optional)

2. **Firestore Database**:
   - Go to **Firestore Database**
   - Click **Create Database**
   - Start in **Production mode**
   - Select region (US-Central or your region)
   
3. **Set Firestore Rules** (Development Mode - Not for Production):
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

---

## Step 3: Fix Android Configuration (Android Build)

Update `android/build.gradle`:

```gradle
// Add Google Services plugin
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Update `android/app/build.gradle`:

```gradle
// At the bottom of the file
apply plugin: 'com.google.gms.google-services'
```

---

## Step 4: Run the App

### For Android

```bash
# Run on connected device or emulator
flutter run

# Or specify device
flutter run -d emulator-5554

# For release build (production)
flutter run --release
```

### For iOS

```bash
# First time setup
cd ios
pod install
cd ..

# Run
flutter run

# For release build
flutter run --release
```

### For Web (if needed)

```bash
flutter run -d chrome
```

---

## Step 5: Verify Everything Works

1. **Splash Screen** appears for 2 seconds
2. **Login Screen** loads
3. **Sign Up** works (create test account)
4. **Login** works with that account
5. **Home Screen** shows event list (empty initially)
6. **Create Event** button works
7. **Event Detail** page opens when tapping an event
8. **Profile Screen** accessible from bottom nav

---

## Troubleshooting

### Issue: "google-services.json not found"
**Solution**: 
- Download from Firebase Console → Project Settings → Android
- Place at `android/app/google-services.json`
- Run `flutter clean && flutter pub get`

### Issue: "FirebaseOptions have not been configured"
**Solution**:
- Run `flutterfire configure` to auto-configure
- Or manually update `lib/firebase_options.dart` with your Firebase credentials

### Issue: "Gradle build fails"
**Solution**:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Issue: "Pod install fails" (iOS)
**Solution**:
```bash
cd ios
rm Podfile.lock
pod repo update
pod install
cd ..
```

### Issue: "Emulator won't start"
**Solution**:
```bash
flutter emulators
flutter emulators launch <emulator_name>
```

### Issue: App crashes on startup
**Solution**:
1. Check Firebase configuration in `lib/firebase_options.dart`
2. Verify Firestore Rules are set in Firebase Console
3. Check logcat: `flutter logs`

---

## Project Structure

```
eventora/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase config (UPDATE THIS!)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── router/
│   │   │   └── app_router.dart      # Navigation setup
│   │   └── theme/
│   │       └── app_theme.dart       # App styling
│   │
│   ├── data/
│   │   ├── models/
│   │   │   └── event_model.dart     # Data models
│   │   ├── repositories/
│   │   │   └── event_repository.dart # Data access
│   │   └── services/
│   │       ├── auth_service.dart    # Auth logic
│   │       └── connectivity_service.dart
│   │
│   └── presentation/
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── events/
│       │   ├── home_screen.dart
│       │   ├── event_detail_screen.dart
│       │   └── create_edit_event_screen.dart
│       ├── profile/
│       │   └── profile_screen.dart
│       ├── splash_screen.dart
│       └── widgets/
│           ├── app_text_field.dart
│           ├── event_card.dart
│           ├── gradient_button.dart
│           └── shimmer_card.dart
│
├── pubspec.yaml                     # All dependencies (UPDATED!)
├── android/
│   └── app/
│       └── google-services.json     # REQUIRED - Download from Firebase
└── ios/
    └── Runner/
        └── GoogleService-Info.plist # REQUIRED - Download from Firebase
```

---

## Dependencies Added/Fixed

✅ All dependencies in `pubspec.yaml` are now complete:
- `firebase_core` & `firebase_auth` - Firebase services
- `cloud_firestore` - Realtime database
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `flutter_animate` - Animations
- `shimmer` - Loading effects
- `flutter_slidable` - Swipeable lists
- `uuid` - Unique IDs
- `google_fonts` - Typography
- `intl` - Date/time formatting
- And others...

---

## Next Steps

After setup works:

1. **Create test account** in Login/Sign Up
2. **Create events** from Home screen
3. **View event details** by tapping events
4. **Delete events** by swiping (on Android)
5. **View profile** in bottom navigation
6. **Test authentication** by logging out

---

## Need Help?

- 📚 [Flutter Docs](https://flutter.dev/docs)
- 🔥 [Firebase Docs](https://firebase.google.com/docs)
- 🐛 Check `flutter logs` for error messages
- 💬 GitHub Issues in the repository

---

## Development Notes

- **Hot Reload**: Press `R` in terminal while app runs to reload changes
- **Hot Restart**: Press `Shift+R` to fully restart app
- **Debug Mode**: Default when running `flutter run`
- **Release Mode**: Use `flutter run --release` for production testing

Good luck! 🚀
