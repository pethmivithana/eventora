import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart' show EventModel, UserModel;
import '../../data/repositories/event_repository.dart';
import '../../data/services/auth_service.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late EventModel _event;
  bool _rsvpLoading = false;
  Map<String, UserModel> _usersCache = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snap = await firestore.collection('users').get();
      final cache = <String, UserModel>{};
      for (final doc in snap.docs) {
        cache[doc.id] = UserModel.fromFirestore(doc);
      }
      if (mounted) {
        setState(() => _usersCache = cache);
      }
    } catch (e) {
      if (mounted) print('[v0] Error loading users: $e');
    }
  }

  bool get _isOwner => _event.userId == _currentUserId;

  Future<void> _toggleRsvp(String status) async {
    setState(() => _rsvpLoading = true);
    try {
      await ref
          .read(eventRepositoryProvider)
          .updateRsvpStatus(_event.id, status);
      
      // Update local state
      final newRsvp = Map<String, String>.from(_event.rsvpStatus);
      newRsvp[_currentUserId!] = status;
      
      setState(() {
        _event = _event.copyWith(
          rsvpStatus: newRsvp,
          isGoing: status == 'going',
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'going'
                  ? 'You\'re going! 🎉'
                  : 'RSVP updated',
            ),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.rose,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _rsvpLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = _event.isUpcoming;
    final currentUserStatus =
        _event.rsvpStatus[_currentUserId] ?? 'pending';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isUpcoming),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _event.title,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusBadge(isUpcoming: isUpcoming),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 8),
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _event.category,
                      style: const TextStyle(
                        color: AppColors.violet,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: 28),

                  // Owner info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.violet.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.violet.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.violet),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organized by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              Text(
                                _usersCache[_event.userId]?.name ??
                                    'Unknown',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isOwner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.violet,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 175.ms),
                  const SizedBox(height: 20),

                  // Details
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date & Time',
                    value: DateFormat('EEEE, MMMM d, yyyy')
                        .format(_event.date),
                    subValue: DateFormat('h:mm a').format(_event.date),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value: _event.location,
                  ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: _event.isPublic
                        ? Icons.public_rounded
                        : Icons.lock_rounded,
                    label: 'Visibility',
                    value: _event.isPublic
                        ? 'Public event'
                        : 'Private - Invite only',
                  ).animate().fadeIn(delay: 275.ms).slideX(begin: -0.1),
                  const SizedBox(height: 28),

                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 28),

                  // Description
                  Text(
                    'About this event',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 10),
                  Text(
                    _event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 40),

                  // Guest List Section (if private event)
                  if (!_event.isPublic && _event.invitedUserIds.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invited Guests',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn(delay: 375.ms),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _event.invitedUserIds.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            itemBuilder: (ctx, idx) {
                              final userId = _event.invitedUserIds[idx];
                              final user = _usersCache[userId];
                              final status =
                                  _event.rsvpStatus[userId] ?? 'pending';
                              final statusColor = status == 'going'
                                  ? AppColors.emerald
                                  : status == 'notGoing'
                                      ? AppColors.rose
                                      : Colors.grey;
                              final statusLabel = status == 'going'
                                  ? 'Going'
                                  : status == 'notGoing'
                                      ? 'Not Going'
                                      : 'Pending';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.violet
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.person_rounded,
                                          color: AppColors.violet),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user?.name ?? 'Unknown',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            user?.email ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(ctx)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.5),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 40),
                      ],
                    ),

                  // RSVP Section (for invited/public events)
                  if (currentUserStatus != null &&
                      !_isOwner) // Owner doesn't RSVP
                    _RsvpSection(
                      currentStatus: currentUserStatus,
                      loading: _rsvpLoading,
                      onGoing: () => _toggleRsvp('going'),
                      onNotGoing: () => _toggleRsvp('notGoing'),
                    ).animate().fadeIn(delay: 425.ms).slideY(begin: 0.2),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, bool isUpcoming) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => context.pop(),
      ),
      actions: _isOwner
          ? [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => context.push(
                  AppConstants.editEventRoute,
                  extra: _event,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.rose, size: 18),
                ),
                onPressed: _confirmDelete,
              ),
              const SizedBox(width: 8),
            ]
          : [
              const SizedBox(width: 8),
            ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _categoryGradient(_event.category),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text(
                  _categoryEmoji(_event.category),
                  style: const TextStyle(fontSize: 64),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
            'Are you sure? This event will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.rose)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref
            .read(eventRepositoryProvider)
            .deleteEvent(_event.id);
        if (mounted) context.go(AppConstants.homeRoute);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting event: $e'),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      }
    }
  }

  List<Color> _categoryGradient(String category) {
    if (category.contains('Tech')) {
      return [const Color(0xFF0EA5E9), const Color(0xFF6366F1)];
    } else if (category.contains('Party')) {
      return [const Color(0xFFF43F5E), const Color(0xFFF97316)];
    } else if (category.contains('Meetup')) {
      return [const Color(0xFF10B981), const Color(0xFF0EA5E9)];
    } else if (category.contains('Music')) {
      return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
    } else if (category.contains('Sports')) {
      return [const Color(0xFF10B981), const Color(0xFF84CC16)];
    } else if (category.contains('Food')) {
      return [const Color(0xFFF59E0B), const Color(0xFFF43F5E)];
    }
    return [AppColors.violet, AppColors.violetLight];
  }

  String _categoryEmoji(String category) {
    final parts = category.split(' ');
    return parts.length > 1 ? parts.last : '📌';
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isUpcoming;
  const _StatusBadge({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isUpcoming
            ? AppColors.emerald.withOpacity(0.12)
            : Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isUpcoming ? AppColors.emerald : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isUpcoming ? 'Upcoming' : 'Completed',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUpcoming ? AppColors.emerald : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.violet.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.violet, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: Theme.of(context).textTheme.titleMedium),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(subValue!,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RsvpSection extends StatelessWidget {
  final String currentStatus;
  final bool loading;
  final VoidCallback onGoing;
  final VoidCallback onNotGoing;

  const _RsvpSection({
    required this.currentStatus,
    required this.loading,
    required this.onGoing,
    required this.onNotGoing,
  });

  @override
  Widget build(BuildContext context) {
    final isGoing = currentStatus == 'going';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Response',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isGoing
                ? AppColors.emerald.withOpacity(0.08)
                : AppColors.rose.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGoing
                  ? AppColors.emerald.withOpacity(0.3)
                  : AppColors.rose.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isGoing
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isGoing ? AppColors.emerald : AppColors.rose,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGoing ? 'You\'re Going' : 'Not Going',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isGoing
                                ? AppColors.emerald
                                : AppColors.rose,
                          ),
                        ),
                        Text(
                          isGoing
                              ? 'You\'re all set for this event'
                              : 'You won\'t attend this event',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : onGoing,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Going'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: loading ? null : onNotGoing,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Not Going'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rose,
                        side: const BorderSide(color: AppColors.rose),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
