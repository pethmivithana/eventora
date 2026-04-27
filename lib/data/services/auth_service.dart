// lib/data/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_model.dart' show UserModel;

// ─── Auth State Stream Provider ───────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  print('[AuthService] Auth state provider watching...');
  return FirebaseAuth.instance.authStateChanges().map((user) {
    print('[AuthService] Auth state changed: user=${user?.uid ?? "null"}');
    return user;
  });
});

// ─── Current User Provider ────────────────────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ─── User Profile Provider ────────────────────────────────────────────────────
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  if (!doc.exists) return null;
  return UserModel.fromFirestore(doc);
});

// ─── Auth Service ─────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Register with email + password, save profile to Firestore
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(name);

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        ).toMap());
  }

  /// Login with email + password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Update display name
  Future<void> updateName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    if (_auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'name': name});
    }
  }
}
