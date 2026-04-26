# Eventora - Complete Setup Guide

## Overview
Eventora is a Flutter event management application built with Firebase, Riverpod, and Go Router.

## Prerequisites
- Flutter SDK (3.5.0 or higher)
- Firebase Account
- Android Studio / Xcode (for mobile development)
- Git

## Step 1: Clone the Repository
```bash
git clone <repository-url>
cd eventora
```

## Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

This will install all required packages:
- **flutter_riverpod**: State management
- **go_router**: Navigation
- **firebase_core, firebase_auth, cloud_firestore**: Backend services
- **google_fonts**: Typography
- **shared_preferences**: Local storage
- **connectivity_plus**: Network connectivity
- **equatable**: Model equality

## Step 3: Setup Firebase Project

### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name: "eventora"
4. Enable Google Analytics (optional)
5. Create project

### 3.2 Enable Authentication
1. In Firebase Console → Authentication
2. Click "Get started"
3. Enable "Email/Password" authentication method
4. Save

### 3.3 Create Firestore Database
1. In Firebase Console → Firestore Database
2. Click "Create database"
3. Select "Start in test mode" (for development)
4. Select region closest to you
5. Create

### 3.4 Configure FlutterFire
Run the FlutterFire CLI to automatically configure your Firebase credentials:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

Follow the prompts:
- Select your Firebase project
- Select platforms: Android, iOS, etc.

This will automatically update `lib/firebase_options.dart` with your credentials.

### 3.5 Manual Configuration (If FlutterFire fails)
If FlutterFire CLI doesn't work, manually update `lib/firebase_options.dart`:

1. Go to Firebase Console → Project Settings
2. Copy your credentials from each app (Android & iOS)
3. Update the values in `firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: '1:YOUR_APP_ID:android:YOUR_HASH',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

## Step 4: Firestore Security Rules (Test Mode)

The app uses test mode by default. For production, set these security rules:

1. Go to Firestore Database → Rules
2. Replace with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

## Step 5: Run the App

### Android
```bash
flutter run -d android
```

### iOS (Mac required)
```bash
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

### Emulator/Simulator
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Troubleshooting

### Issue: "flutter_riverpod" not found
**Solution**: Run `flutter pub get` again

### Issue: Firebase credentials not configured
**Solution**: Run `flutterfire configure` or manually update `firebase_options.dart`

### Issue: Firestore not working
**Solution**: 
1. Check Firebase project is created
2. Enable Firestore Database
3. Update security rules to test mode
4. Ensure authentication is enabled

### Issue: Pod install fails (iOS)
**Solution**:
```bash
cd ios
rm Podfile.lock
pod repo update
pod install
cd ..
```

### Issue: Gradle build fails (Android)
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── constants/            # App constants
│   ├── router/               # Navigation routing
│   └── theme/                # Theme & styling
├── data/
│   ├── models/               # Data models (EventModel, UserModel)
│   ├── repositories/         # Data repositories
│   └── services/             # Firebase & connectivity services
└── presentation/
    ├── auth/                 # Login & register screens
    ├── events/               # Event management screens
    ├── profile/              # User profile
    ├── splash_screen.dart    # Splash/loading screen
    └── widgets/              # Reusable UI components
```

## Features

- ✅ User Authentication (Email/Password)
- ✅ Create/Edit/Delete Events
- ✅ Event Categories & Filtering
- ✅ RSVP to Events
- ✅ User Profiles
- ✅ Dark/Light Theme
- ✅ Offline Support (Connectivity detection)
- ✅ Smooth Animations & Transitions

## Development Tips

### Hot Reload
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### View Logs
```bash
flutter logs
```

### Build Release
```bash
flutter build apk       # Android APK
flutter build ios       # iOS app
```

## Dependencies Versions

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.5.0 | State management |
| go_router | ^14.6.0 | Navigation |
| firebase_core | ^4.7.0 | Firebase initialization |
| firebase_auth | ^6.4.0 | Authentication |
| cloud_firestore | ^6.3.0 | Database |
| google_fonts | ^7.0.0 | Custom fonts |
| shared_preferences | ^2.2.3 | Local storage |
| connectivity_plus | ^5.0.2 | Network detection |
| equatable | ^2.0.5 | Model equality |

## Support & Issues

For issues or questions:
1. Check Troubleshooting section above
2. Review error messages in logs
3. Visit Flutter documentation: https://flutter.dev
4. Visit Firebase documentation: https://firebase.google.com/docs/flutter

---

Happy coding! 🚀
