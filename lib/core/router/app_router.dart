// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/event_model.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/events/create_edit_event_screen.dart';
import '../../presentation/events/event_detail_screen.dart';
import '../../presentation/events/home_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppConstants.loginRoute,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Route Error'),
            const SizedBox(height: 16),
            Text(state.error?.toString() ?? 'Unknown error'),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // Handle different auth states
      if (authState.isLoading) {
        // While loading, stay on current route or login
        return state.matchedLocation == AppConstants.loginRoute ||
                state.matchedLocation == AppConstants.registerRoute
            ? null
            : AppConstants.loginRoute;
      }

      if (authState.hasError) {
        // If there's an error, go to login
        return AppConstants.loginRoute;
      }

      final isAuthenticated = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == AppConstants.loginRoute ||
          state.matchedLocation == AppConstants.registerRoute;

      // If authenticated, allow navigation (but redirect from auth pages to home)
      if (isAuthenticated) {
        if (isOnAuth) {
          return AppConstants.homeRoute;
        }
        return null;
      }

      // If not authenticated, only allow auth pages
      if (isOnAuth) {
        return null;
      }

      // Otherwise redirect to login
      return AppConstants.loginRoute;
    },
    routes: [
      GoRoute(
        path: AppConstants.loginRoute,
        pageBuilder: (_, state) => _fadeTransition(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        pageBuilder: (_, state) => _fadeTransition(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        pageBuilder: (_, state) => _fadeTransition(
          state,
          const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.createEventRoute,
        pageBuilder: (_, state) => _slideTransition(
          state,
          const CreateEditEventScreen(),
        ),
      ),
      GoRoute(
        path: AppConstants.editEventRoute,
        pageBuilder: (_, state) {
          final event = state.extra as EventModel;
          return _slideTransition(
            state,
            CreateEditEventScreen(event: event),
          );
        },
      ),
      GoRoute(
        path: AppConstants.eventDetailRoute,
        pageBuilder: (_, state) {
          final event = state.extra as EventModel;
          return _slideTransition(
            state,
            EventDetailScreen(event: event),
          );
        },
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        pageBuilder: (_, state) => _slideTransition(
          state,
          const ProfileScreen(),
        ),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
});

CustomTransitionPage<void> _fadeTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

CustomTransitionPage<void> _slideTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
          position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
