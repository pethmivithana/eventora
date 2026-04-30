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
    bool isPublic = true,
    List<String> invitedUsers = const [],
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
      ownerId: userId,
      isPublic: isPublic,
      invitedUsers: invitedUsers,
      attendees: {userId: RSVPStatus.going}, // creator is going by default
      createdAt: DateTime.now(),
    );
    await _eventsRef.doc(id).set(event.toMap());
  }

  // ── READ (stream) ─────────────────────────────────────────────────────────
  /// Watch events visible to current user (public + private invites + owned)
  Stream<List<EventModel>> watchEvents() {
    return _eventsRef
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) {
          final allEvents = snap.docs.map((d) => EventModel.fromFirestore(d)).toList();
          // Filter to show only: public events + events user is invited to + events user owns
          return allEvents.where((e) {
            return e.isPublic || 
                   e.ownerId == userId || 
                   e.invitedUsers.contains(userId);
          }).toList();
        });
  }

  /// Watch only events created by current user
  Stream<List<EventModel>> watchMyEvents() {
    return _eventsRef
        .where('ownerId', isEqualTo: userId)
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
  /// Update event - only owner can update
  Future<void> updateEvent(EventModel event) async {
    if (event.ownerId != userId) {
      throw Exception('Only event owner can update this event');
    }
    // Auto-compute status based on date
    final updated = event.copyWith(
      status: event.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Completed',
    );
    await _eventsRef.doc(event.id).update(updated.toMap());
  }

  // ── RSVP ──────────────────────────────────────────────────────────────────
  /// Update RSVP status for current user
  Future<void> updateRsvp(String eventId, RSVPStatus status) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    
    final updated = event.attendees;
    updated[userId] = status;
    
    await _eventsRef.doc(eventId).update({
      'attendees': updated.map((k, v) => MapEntry(k, v.name)),
    });
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  /// Delete event - only owner can delete
  Future<void> deleteEvent(String id) async {
    final event = await getEvent(id);
    if (event == null) throw Exception('Event not found');
    if (event.ownerId != userId) {
      throw Exception('Only event owner can delete this event');
    }
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
