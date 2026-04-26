// lib/data/repositories/event_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/event_model.dart';
import '../services/auth_service.dart';

// ─── Providers ────────────────────────────────────────────────────────────────
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  return EventRepository(userId: user?.uid ?? '');
});

/// Real-time stream of all events for current user
final userEventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.watchEvents();
});

// ─── Event Repository ─────────────────────────────────────────────────────────
class EventRepository {
  final String userId;
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  EventRepository({required this.userId});

  CollectionReference get _eventsRef =>
      _firestore.collection('events');

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String category,
  }) async {
    final id = _uuid.v4();
    final event = EventModel(
      id: id,
      title: title,
      description: description,
      date: date,
      location: location,
      category: category,
      status: date.isAfter(DateTime.now()) ? 'Upcoming' : 'Completed',
      userId: userId,
      isGoing: true, // creator is going by default
      createdAt: DateTime.now(),
    );
    await _eventsRef.doc(id).set(event.toMap());
  }

  // ── READ (stream) ─────────────────────────────────────────────────────────
  Stream<List<EventModel>> watchEvents() {
    return _eventsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
  }

  // ── READ (once) ───────────────────────────────────────────────────────────
  Future<EventModel?> getEvent(String id) async {
    final doc = await _eventsRef.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<void> updateEvent(EventModel event) async {
    // Auto-compute status based on date
    final updated = event.copyWith(
      status: event.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Completed',
    );
    await _eventsRef.doc(event.id).update(updated.toMap());
  }

  // ── TOGGLE RSVP ───────────────────────────────────────────────────────────
  Future<void> toggleRsvp(String eventId, bool currentValue) async {
    await _eventsRef.doc(eventId).update({'isGoing': !currentValue});
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteEvent(String id) async {
    await _eventsRef.doc(id).delete();
  }

  // ── SEARCH + FILTER ───────────────────────────────────────────────────────
  /// Client-side filtering after stream fetch
  static List<EventModel> applyFilters({
    required List<EventModel> events,
    required String query,
    required String categoryFilter,
    required String statusFilter,
  }) {
    return events.where((e) {
      // Search by title or location
      final q = query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q);

      // Category filter
      final matchesCategory =
          categoryFilter == 'All' || e.category == categoryFilter;

      // Status filter
      final matchesStatus =
          statusFilter == 'All' || e.autoStatus == statusFilter;

      return matchesQuery && matchesCategory && matchesStatus;
    }).toList();
  }
}