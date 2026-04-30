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

/// Real-time stream of all events for current user (owned + public + invited)
final userEventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.watchAllAccessibleEvents();
});

/// Real-time stream of owned events only
final ownedEventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.watchOwnedEvents();
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
    List<String> invitedUserIds = const [],
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
      isPublic: isPublic,
      invitedUserIds: invitedUserIds,
      rsvpStatus: {userId: 'going'}, // owner is automatically going
    );
    await _eventsRef.doc(id).set(event.toMap());
  }

  // ── READ (stream) - owned events only ──────────────────────────────────────
  Stream<List<EventModel>> watchOwnedEvents() {
    return _eventsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
  }

  // ── READ (stream) - all accessible events ──────────────────────────────────
  /// Returns owned events + public events + invited private events
  Stream<List<EventModel>> watchAllAccessibleEvents() {
    return _eventsRef
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) {
      final allEvents = snap.docs.map((d) => EventModel.fromFirestore(d)).toList();
      // Filter to show only:
      // 1. Events owned by user
      // 2. Public events
      // 3. Private events where user is invited
      return allEvents.where((event) {
        return event.userId == userId || // owned
            event.isPublic || // public
            event.invitedUserIds.contains(userId); // invited to private
      }).toList();
    });
  }

  // ── READ (once) ───────────────────────────────────────────────────────────
  Future<EventModel?> getEvent(String id) async {
    final doc = await _eventsRef.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  // ── CHECK OWNERSHIP ──────────────────────────────────────────────────────────
  Future<bool> isEventOwner(String eventId) async {
    final event = await getEvent(eventId);
    return event?.userId == userId;
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<void> updateEvent(EventModel event) async {
    if (event.userId != userId) {
      throw Exception('Only event owner can update');
    }
    // Auto-compute status based on date
    final updated = event.copyWith(
      status: event.date.isAfter(DateTime.now()) ? 'Upcoming' : 'Completed',
    );
    await _eventsRef.doc(event.id).update(updated.toMap());
  }

  // ── TOGGLE RSVP (old style - for backward compatibility) ────────────────────
  Future<void> toggleRsvp(String eventId, bool currentValue) async {
    await _eventsRef.doc(eventId).update({'isGoing': !currentValue});
  }

  // ── UPDATE RSVP STATUS (new method) ────────────────────────────────────────
  Future<void> updateRsvpStatus(String eventId, String status) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');

    final updatedRsvp = Map<String, String>.from(event.rsvpStatus);
    updatedRsvp[userId] = status; // 'going', 'notGoing', or 'pending'

    await _eventsRef.doc(eventId).update({
      'rsvpStatus': updatedRsvp,
      'isGoing': status == 'going', // sync with old field for compatibility
    });
  }

  // ── INVITE USERS ───────────────────────────────────────────────────────────
  Future<void> inviteUsers(String eventId, List<String> userIds) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    if (event.userId != userId) throw Exception('Only event owner can invite');

    final updatedInvited = <String>{...event.invitedUserIds, ...userIds}.toList();
    final updatedRsvp = Map<String, String>.from(event.rsvpStatus);

    // Add invited users with pending status if not already there
    for (final uid in userIds) {
      updatedRsvp.putIfAbsent(uid, () => 'pending');
    }

    await _eventsRef.doc(eventId).update({
      'invitedUserIds': updatedInvited,
      'rsvpStatus': updatedRsvp,
    });
  }

  // ── REMOVE INVITE ──────────────────────────────────────────────────────────
  Future<void> removeInvite(String eventId, String userId) async {
    final event = await getEvent(eventId);
    if (event == null) throw Exception('Event not found');
    if (event.userId != this.userId) throw Exception('Only event owner can remove invites');

    final updatedInvited = event.invitedUserIds.where((id) => id != userId).toList();
    final updatedRsvp = Map<String, String>.from(event.rsvpStatus);
    updatedRsvp.remove(userId);

    await _eventsRef.doc(eventId).update({
      'invitedUserIds': updatedInvited,
      'rsvpStatus': updatedRsvp,
    });
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteEvent(String id) async {
    final event = await getEvent(id);
    if (event?.userId != userId) {
      throw Exception('Only event owner can delete');
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
