// lib/core/constants/app_constants.dart

class AppConstants {
  // Firestore collections
  static const String eventsCollection = 'events';
  static const String usersCollection = 'users';

  // Event categories
  static const List<String> categories = [
    'All',
    'Party 🎉',
    'Tech 💻',
    'Meetup 🤝',
    'Workshop 🛠️',
    'Sports ⚽',
    'Music 🎵',
    'Food 🍕',
    'Art 🎨',
    'Other 📌',
  ];

  // Event status
  static const String statusUpcoming = 'Upcoming';
  static const String statusCompleted = 'Completed';

  // Filter options for status
  static const List<String> statusFilters = [
    'All',
    'Upcoming',
    'Completed',
  ];

  // Route names
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String createEventRoute = '/events/create';
  static const String editEventRoute = '/events/edit';
  static const String eventDetailRoute = '/events/detail';
  static const String profileRoute = '/profile';
}