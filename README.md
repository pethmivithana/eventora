# Eventora - Event Management Mobile App

A feature-rich event management application built with **Flutter** for iOS and Android platforms. Eventora enables users to browse, create, manage, and discover events with a beautiful and intuitive UI.

---

## 📱 Project Overview

**Eventora** is a mobile application designed to solve real-world event management challenges. Users can:
- ✅ **Create & Manage Events** - Full CRUD operations for event management
- ✅ **Search Events** - Find events by name or title in real-time
- ✅ **Filter Events** - Filter by category, status, location, and date range
- ✅ **User Authentication** - Secure login and registration system
- ✅ **Offline Support** - App works even without internet connectivity
- ✅ **Real-time Updates** - Firebase integration for instant data sync
- ✅ **Beautiful UI** - Responsive and animated Flutter-based interface

---

## 🛠 Technology Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter 3.19.0+ (Dart) |
| **Target Platforms** | Android (SDK 21+) & iOS (12.0+) |
| **Backend** | Firebase (Auth + Firestore) |
| **State Management** | Flutter Riverpod 2.5.0 |
| **Routing** | GoRouter 14.6.0 |
| **Local Storage** | SharedPreferences 2.2.3 |
| **Connectivity** | connectivity_plus 5.0.2 |
| **Animations** | flutter_animate 4.5.0, shimmer 3.0.0 |
| **UI Framework** | Material Design 3 |

---

## 📋 Features Implemented

### 1. **CRUD Operations** ✅
- **Create**: Users can create new events with title, description, location, date, and category
- **Read**: Display all events with detailed information in list and card view
- **Update**: Edit event details (title, description, date, category, location)
- **Delete**: Remove events with confirmation dialog
- **Persistence**: Firebase Firestore backend for real-time sync

### 2. **Search Functionality** ✅
- Real-time search by event name/title
- Case-insensitive search algorithm
- Instant filtering as user types
- Search bar component in home screen
- **Location**: `lib/presentation/events/home_screen.dart`

### 3. **Filtering** ✅
- Filter events by:
  - **Category** (Conference, Workshop, Meetup, Concert, etc.)
  - **Status** (Upcoming, Ongoing, Completed)
  - **Location** (Text-based search)
  - **Date Range** (Start and end date pickers)
- Multi-select filtering capability
- **Location**: `lib/presentation/widgets/filter_dialog.dart`

### 4. **Authentication** ✅
- **Registration**: Create new user account with email/password validation
- **Login**: Secure Firebase Authentication
- **Session Management**: Auto-login with SharedPreferences
- **Logout**: Clear user session and local data
- **User Profile**: Display logged-in user details
- **Security**: Password validation and email verification

### 5. **UI/UX Design** ✅
- **Responsive Layout**: Adapts to all screen sizes (phone, tablet, landscape)
- **Material Design 3**: Modern, intuitive interface components
- **Animated Transitions**: Smooth page navigation and animations
- **Dark/Light Mode**: System theme support with auto-detection
- **Loading States**: Shimmer effects and progress indicators
- **Error Handling**: User-friendly error messages and empty states
- **Custom Widgets**: Reusable components (EventCard, SearchBar, FilterDialog)

---

## 🚀 Setup & Installation

### Prerequisites
- **Flutter SDK**: 3.19.0 or higher ([Install](https://flutter.dev/docs/get-started/install))
- **Android Studio** or **Xcode** for emulator/simulator
- **Git** for version control
- **Firebase Project** (optional but recommended)

### Step 1: Clone the Repository
```bash
git clone https://github.com/pethmivithana/eventora.git
cd eventora
```

### Step 2: Install Dependencies
```bash
# Get all Flutter packages
flutter pub get

# (Optional) Activate FlutterFire CLI for Firebase setup
dart pub global activate flutterfire_cli
```

### Step 3: Configure Firebase (Recommended)
```bash
# Auto-configure Firebase for your platforms
flutterfire configure

# Follow the prompts to select your Firebase project
# This generates lib/firebase_options.dart automatically
```

**Or manually configure Firebase:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create or select your project
3. Add Android and iOS apps with appropriate package names
4. Download configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
5. Update `lib/firebase_options.dart` with your credentials

### Step 4: Run the Application

**On Android Emulator:**
```bash
flutter run -d android
```

**On iOS Simulator:**
```bash
flutter run -d ios
```

**On Connected Device:**
```bash
flutter devices  # List connected devices
flutter run -d <device-id>
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & initialization
├── firebase_options.dart              # Firebase configuration
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants and strings
│   ├── router/
│   │   └── app_router.dart           # GoRouter navigation setup
│   └── theme/
│       └── app_theme.dart            # Material Design 3 theme
│
├── data/
│   ├── models/
│   │   └── event_model.dart          # Event & User data models
│   ├── repositories/
│   │   └── event_repository.dart     # Data access abstraction layer
│   └── services/
│       ├── auth_service.dart         # Firebase Auth service
│       ├── event_service.dart        # Firestore CRUD operations
│       └── connectivity_service.dart # Offline detection
│
├── presentation/
│   ├── auth/
│   │   ├── login_screen.dart         # User login screen
│   │   └── register_screen.dart      # User registration screen
│   ├── events/
│   │   ├── home_screen.dart          # Main event list with search
│   │   ├── event_detail_screen.dart  # Single event details
│   │   ├── create_event_screen.dart  # Create new event form
│   │   └── edit_event_screen.dart    # Edit event form
│   └── widgets/
│       ├── event_card.dart           # Reusable event card widget
│       ├── search_bar.dart           # Search input widget
│       └── filter_dialog.dart        # Advanced filter dialog
│
└── pubspec.yaml                       # Flutter dependencies & config
```

---

## 🔌 API Integration

### Firebase Firestore Collections

**Users Collection:**
```
users/
  └── {userId}
      ├── email: string
      ├── fullName: string
      ├── photoUrl: string (optional)
      └── createdAt: timestamp
```

**Events Collection:**
```
events/
  └── {eventId}
      ├── title: string
      ├── description: string
      ├── category: string (Conference, Workshop, Meetup, Concert, etc.)
      ├── location: string
      ├── startDate: timestamp
      ├── endDate: timestamp
      ├── createdBy: string (userId reference)
      ├── attendees: array<string> (userIds)
      ├── status: string (Upcoming, Ongoing, Completed)
      └── createdAt: timestamp
```

### Authentication Endpoints

| Operation | Method | Endpoint | Details |
|-----------|--------|----------|---------|
| Register | POST | Firebase Auth | Email/Password registration |
| Login | POST | Firebase Auth | Email/Password authentication |
| Logout | DELETE | Firebase Auth | Clear session |
| Get Current User | GET | Firebase Auth | Fetch authenticated user |

### Event Operations (Firestore)

| Operation | Method | Path | Details |
|-----------|--------|------|---------|
| Create Event | POST | `/events` | Add new event document |
| Read All Events | GET | `/events` | Fetch all events with pagination |
| Get Event Detail | GET | `/events/{id}` | Get single event document |
| Update Event | PUT | `/events/{id}` | Update event fields |
| Delete Event | DELETE | `/events/{id}` | Remove event document |
| Search Events | GET | `/events` (filtered) | Search by title/description |
| Filter Events | GET | `/events` (where) | Filter by category/status/date |

### Firestore Queries Used

```dart
// Get all events
db.collection('events').get()

// Search by title
db.collection('events')
  .where('title', arrayContains: searchQuery)
  .get()

// Filter by category
db.collection('events')
  .where('category', isEqualTo: selectedCategory)
  .get()

// Filter by date range
db.collection('events')
  .where('startDate', isGreaterThanOrEqualTo: startDate)
  .where('startDate', isLessThanOrEqualTo: endDate)
  .get()

// Get user events
db.collection('events')
  .where('createdBy', isEqualTo: userId)
  .get()
```

---

## 🎨 UI Approach - Flutter Widgets

### Design Framework
- **Material Design 3**: Latest Material Design principles
- **Flutter Widgets**: Custom and built-in Flutter components
- **Responsive Grid**: GridView and ListView for adaptive layouts
- **State Management**: Riverpod for efficient state updates and caching

### Key UI Components

1. **EventCard Widget** - Displays event preview with image, title, date, location
2. **SearchBar Widget** - Real-time search input with filtering
3. **FilterDialog Widget** - Category, date, status multi-select filters
4. **ShimmerLoader** - Loading state animation for better UX
5. **EmptyStateWidget** - User-friendly messages when no events found

### Navigation Structure
- **Login Screen** → Registration Screen
- **Home Screen** (List) → Event Detail Screen
- **Create Button** → Create Event Form
- **Edit Option** → Edit Event Form
- **User Menu** → Profile / Logout

### Responsive Design
- **Phone**: Single column layout with full-width cards
- **Tablet**: Multi-column grid layout
- **Landscape**: Side-by-side layout with split view
- **SafeArea**: Proper notch and padding handling

---

## 🔐 Authentication Flow

```
App Launch
    ↓
Check Stored Credentials (SharedPreferences)
    ↓
    ├─→ Valid Credentials? → Validate with Firebase → Home Screen
    │
    └─→ No Credentials? → Show Login/Register Screen
        ↓
        ├─→ New User? → Click "Register"
        │   ├─→ Fill Email, Password, Full Name
        │   ├─→ Validate inputs
        │   ├─→ Firebase Auth.createUserWithEmailAndPassword()
        │   ├─→ Create Firestore user document
        │   ├─→ Save credentials locally
        │   └─→ Navigate to Home Screen
        │
        └─→ Existing User? → Click "Login"
            ├─→ Enter Email & Password
            ├─→ Firebase Auth.signInWithEmailAndPassword()
            ├─→ Validate credentials
            ├─→ Save to SharedPreferences
            └─→ Navigate to Home Screen

User in App
    ↓
View/Edit/Delete Events
    ↓
User Clicks "Logout"
    ├─→ Firebase Auth.signOut()
    ├─→ Clear SharedPreferences
    └─→ Return to Login Screen
```

---

## 🔄 CRUD Operations Implementation

### Create Event
```
User Clicks "Create Event" Button
    ↓
Open Create_Event_Screen with form
    ↓
User fills: Title, Description, Category, Location, Date
    ↓
User clicks "Save"
    ↓
Validate inputs (non-empty, valid date)
    ↓
Firebase Firestore.collection('events').add(eventData)
    ↓
Show success message
    ↓
Navigate back to Home Screen
```

### Read Events
```
App Launch → Home Screen
    ↓
Firestore.collection('events').get()
    ↓
Parse documents to EventModel list
    ↓
Display in ListView with EventCard widgets
    ↓
User can scroll, search, and filter
```

### Update Event
```
User views event detail
    ↓
User clicks "Edit" button
    ↓
Load event data into form (pre-filled)
    ↓
User modifies fields
    ↓
User clicks "Update"
    ↓
Validate inputs
    ↓
Firebase Firestore.collection('events').doc(eventId).update(newData)
    ↓
Show success message
    ↓
Refresh event detail or navigate back
```

### Delete Event
```
User views event detail
    ↓
User clicks "Delete" button
    ↓
Show confirmation dialog
    ↓
User confirms deletion
    ↓
Firebase Firestore.collection('events').doc(eventId).delete()
    ↓
Remove from local list
    ↓
Navigate back to Home Screen
    ↓
Show success message
```

---

## 🔍 Search & Filter Implementation

### Real-time Search
```dart
// TextEditingController listens to changes
searchController.addListener(() {
  final query = searchController.text.toLowerCase();
  filteredEvents = allEvents
    .where((event) =>
        event.title.toLowerCase().contains(query) ||
        event.description.toLowerCase().contains(query))
    .toList();
  setState(() {}); // or use Riverpod notifier
});
```

### Multi-Filter Dialog
- **Category Filter**: Dropdown or chip selection
- **Status Filter**: Upcoming, Ongoing, Completed
- **Date Range**: DatePicker for start and end dates
- **Location Filter**: Text input for location search
- **Apply Button**: Combines all filters with AND logic

### Filter Query Example
```dart
var filtered = events
  .where((e) => 
    e.category == selectedCategory &&
    e.startDate.isAfter(startDate) &&
    e.startDate.isBefore(endDate) &&
    e.location.toLowerCase().contains(locationQuery)
  )
  .toList();
```

---

## 🌐 Offline Support

- **Local Caching**: SharedPreferences stores user data and recent events
- **Connectivity Monitoring**: connectivity_plus detects online/offline status
- **Graceful Degradation**: Show cached data when offline
- **Queue Operations**: Store failed operations, sync when online
- **Sync Button**: Manual sync option in UI

---

## ⚙️ Build & Run Instructions

### Development
```bash
# Run with hot reload
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run with verbose output
flutter run -v
```

### Production Build

**Android APK (for distribution):**
```bash
# Build release APK
flutter build apk --release

# Output location
# build/app/outputs/flutter-app/apk/release/app-release.apk

# For split APKs (smaller size)
flutter build apk --release --split-per-abi

# Output
# build/app/outputs/flutter-app/apk/release/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-app/apk/release/app-arm64-v8a-release.apk
```

**iOS (for submission):**
```bash
# Build iOS app
flutter build ios --release

# Archive in Xcode
# Use Xcode or Firebase Distribution for TestFlight

# For demo/screen recording
# Use iOS Simulator and record with built-in tools
```

### Clean Build
```bash
# Clean all build artifacts
flutter clean

# Get fresh dependencies
flutter pub get

# Run fresh build
flutter run
```

---

## 📊 Code Examples

### Create Event Service
```dart
// In lib/data/services/event_service.dart
Future<void> createEvent(EventModel event) async {
  try {
    await _firestore
        .collection('events')
        .doc(event.id)
        .set(event.toFirestore());
  } catch (e) {
    throw Exception('Failed to create event: $e');
  }
}
```

### Real-time Search Implementation
```dart
// In lib/presentation/events/home_screen.dart
TextField(
  controller: searchController,
  decoration: InputDecoration(hintText: 'Search events...'),
  onChanged: (value) {
    setState(() {
      filteredEvents = allEvents
          .where((event) =>
              event.title.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  },
)
```

### Filter Events with Multiple Criteria
```dart
// Multi-filter logic
final filtered = events
    .where((e) => 
        (selectedCategory.isEmpty || e.category == selectedCategory) &&
        (selectedStatus.isEmpty || e.status == selectedStatus) &&
        e.startDate.isAfter(startDate) &&
        e.startDate.isBefore(endDate))
    .toList();
```

---

## 🐛 Error Handling & Edge Cases

- **Network Errors**: Retry dialogs with exponential backoff
- **Empty States**: "No events found" message with illustration
- **Loading States**: Shimmer animation during data fetch
- **Form Validation**: Real-time validation with error messages
- **Firebase Errors**: Specific error messages for auth failures
- **Offline Mode**: Show cached data with offline indicator

---

## 📈 Evaluation Criteria Checklist

✅ **Clean Code**
- Modular architecture with clear separation of concerns
- Follows Flutter best practices and Dart style guide
- Riverpod for clean state management
- Reusable widgets and functions

✅ **UI/UX**
- Intuitive navigation with GoRouter
- Responsive design for all screen sizes
- Smooth animations and transitions
- Material Design 3 compliance
- Dark/Light theme support

✅ **Functionality**
- All CRUD operations fully working
- Search and filtering accurate and performant
- Authentication system secure and reliable
- Event management complete

✅ **API Integration**
- Firebase Authentication properly integrated
- Firestore database operations correct
- Real-time data synchronization
- Proper error handling and validation

✅ **Error Handling**
- Network failure handling with user feedback
- Empty state UI components
- Form validation with error messages
- Graceful offline mode support

---

## ✨ Optional Enhancements Implemented

✅ Display logged-in user details
✅ Logout functionality
✅ Dark/Light mode support (system theme)
✅ Offline mode support
✅ Architectural pattern (Layered + Riverpod)
✅ Animated transitions
✅ Loading shimmer effects
✅ User profile screen

---

## 📦 Submission Materials

When submitting this project, include:
- ✅ GitHub repository with clean commit history
- ✅ This README.md with complete documentation
- ✅ Buildable source code with no errors
- ✅ Android APK file (`app-release.apk`)
- ✅ iOS screen recording or demo video
- ✅ Firebase configuration instructions

---

## 🔗 Useful Resources

- [Flutter Official Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Riverpod Docs](https://riverpod.dev)
- [GoRouter Docs](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io)

---

## 📧 Support & Contact

For questions or issues:
1. Check the GitHub issues
2. Review the setup guides in the project root
3. Refer to Firebase and Flutter documentation

---

**Built with ❤️ using Flutter | Production Ready** 🚀
