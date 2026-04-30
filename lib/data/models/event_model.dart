// lib/data/models/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String category;
  final String status; // 'Upcoming' | 'Completed'
  final String userId; // creator/owner
  final bool isGoing; // RSVP
  final DateTime createdAt;
  final bool isPublic; // true: visible to all, false: private invite-only
  final List<String> invitedUserIds; // list of invited user IDs
  final Map<String, String> rsvpStatus; // userId -> 'going' | 'notGoing' | 'pending'

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.userId,
    required this.isGoing,
    required this.createdAt,
    this.isPublic = true,
    this.invitedUserIds = const [],
    this.rsvpStatus = const {},
  });

  // ── Computed Properties ──────────────────────────────────────────────────
  bool get isUpcoming => date.isAfter(DateTime.now());
  String get autoStatus => isUpcoming ? 'Upcoming' : 'Completed';

  // ── Factory ──────────────────────────────────────────────────────────────
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rsvpData = data['rsvpStatus'] as Map<String, dynamic>?;
    final invitedList = data['invitedUserIds'] as List?;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      category: data['category'] ?? 'Other 📌',
      status: data['status'] ?? 'Upcoming',
      userId: data['userId'] ?? '',
      isGoing: data['isGoing'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPublic: data['isPublic'] ?? true,
      invitedUserIds: invitedList != null ? List<String>.from(invitedList) : [],
      rsvpStatus: rsvpData != null ? Map<String, String>.from(rsvpData) : {},
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
      'userId': userId,
      'isGoing': isGoing,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'invitedUserIds': invitedUserIds,
      'rsvpStatus': rsvpStatus,
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
    String? userId,
    bool? isGoing,
    DateTime? createdAt,
    bool? isPublic,
    List<String>? invitedUserIds,
    Map<String, String>? rsvpStatus,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      isGoing: isGoing ?? this.isGoing,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, date, location,
    category, status, userId, isGoing, createdAt,
    isPublic, invitedUserIds, rsvpStatus,
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
