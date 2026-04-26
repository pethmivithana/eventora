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
  final String userId;
  final bool isGoing; // RSVP
  final DateTime createdAt;

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
  });

  // ── Computed Properties ──────────────────────────────────────────────────
  bool get isUpcoming => date.isAfter(DateTime.now());
  String get autoStatus => isUpcoming ? 'Upcoming' : 'Completed';

  // ── Factory ──────────────────────────────────────────────────────────────
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, date, location,
        category, status, userId, isGoing, createdAt,
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