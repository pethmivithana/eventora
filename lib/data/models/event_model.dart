// lib/data/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RSVPStatus { notResponded, going, notGoing }

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category;
  final String status; // 'Upcoming' | 'Completed'
  final String ownerId; // User who created the event
  final bool isPublic; // Public or private event
  final List<String> invitedUsers; // List of invited user IDs
  final Map<String, RSVPStatus> attendees; // userId -> RSVP status
  final DateTime createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.ownerId,
    this.isPublic = true,
    this.invitedUsers = const [],
    this.attendees = const {},
    required this.createdAt,
  });

  // ── Computed Properties ──────────────────────────────────────────────────
  bool get isUpcoming => date.isAfter(DateTime.now());
  String get autoStatus => isUpcoming ? 'Upcoming' : 'Completed';

  // ── Factory ──────────────────────────────────────────────────────────────
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse attendees map
    Map<String, RSVPStatus> attendees = {};
    if (data['attendees'] != null) {
      (data['attendees'] as Map).forEach((key, value) {
        attendees[key] = RSVPStatus.values.firstWhere(
          (e) => e.toString() == 'RSVPStatus.$value',
          orElse: () => RSVPStatus.notResponded,
        );
      });
    }
    
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      category: data['category'] ?? 'Other 📌',
      status: data['status'] ?? 'Upcoming',
      ownerId: data['ownerId'] ?? '',
      isPublic: data['isPublic'] ?? true,
      invitedUsers: List<String>.from(data['invitedUsers'] ?? []),
      attendees: attendees,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // ── To Map ───────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category,
      'status': status,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'invitedUsers': invitedUsers,
      'attendees': attendees.map((key, value) => MapEntry(key, value.name)),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // ── CopyWith ─────────────────────────────────────────────────────────────
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? category,
    String? status,
    String? ownerId,
    bool? isPublic,
    List<String>? invitedUsers,
    Map<String, RSVPStatus>? attendees,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, date, location,
        category, status, ownerId, isPublic, invitedUsers, attendees, createdAt,
      ];
}

// ─── User Model ───────────────────────────────────────────────────────────────
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [id, name, email, createdAt];
}
