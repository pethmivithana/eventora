# 🎉 Eventora - Event Management App

A modern Flutter-based mobile app for creating, managing, and discovering events with a smooth and user-friendly experience.

## 📱 Overview

Eventora helps users handle events easily in one place.

## ✨ Key Features

- 📝 **Create, Edit, Delete Events** (Full CRUD)
- 🔍 **Real-time Search**
- 🎯 **Advanced Filtering** (category, date, status, location)
- 🔐 **Authentication** (Firebase login & registration)
- 🌐 **Offline Support**
- ⚡ **Real-time Sync** with Firebase
- 🎨 **Clean & Responsive UI** (Material 3)

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Auth + Firestore)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Local Storage:** SharedPreferences
- **Connectivity:** connectivity_plus

## 📂 Project Structure

```
lib/
├── core/            # Constants, theme, routing
├── data/            # Models, services, repositories
├── presentation/    # UI screens & widgets
└── main.dart        # Entry point
```

## 🔐 Authentication Flow

```
Launch App
   ↓
Check Login
   ↓
Login / Register
   ↓
Home Screen
   ↓
Logout → Back to Login
```

## 🔄 CRUD Operations

- ➕ **Create Event**
- 📖 **Read Events**
- ✏️ **Update Event**
- ❌ **Delete Event**

All data is stored in Firebase Firestore.

## 🔍 Search & Filter

- 🔎 **Search** by event title (real-time)
- 🎯 **Filter** by:
  - Category
  - Status
  - Date range
  - Location

## 🌐 Offline Support

- 📦 Cached data using SharedPreferences
- 📡 Detects connection status
- 🔄 Syncs when back online

## 🚀 Setup

### 1. Clone Project
```bash
git clone https://github.com/pethmivithana/eventora.git
cd eventora
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup (Recommended)
```bash
flutterfire configure
```

### 4. Run App
```bash
flutter run
```

## 📦 Build

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 UI Highlights

- 📱 Responsive design (phone + tablet)
- 🌙 Dark / Light mode
- ✨ Smooth animations
- ⏳ Loading shimmer effects

## ⚠️ Error Handling

- Network failure handling
- Form validation
- Empty states UI
- Firebase error messages
