// lib/presentation/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

class EventCard extends ConsumerWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpcoming = event.isUpcoming;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.35,
          children: [
            SlidableAction(
              onPressed: (_) => _confirmDelete(context, ref),
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => context.push(AppConstants.eventDetailRoute, extra: event),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category emoji circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _categoryGradient(event.category),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          _categoryEmoji(event.category),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusDot(isUpcoming: isUpcoming),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.violet,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  color: Theme.of(context).dividerColor,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('MMM d, yyyy').format(event.date),
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: DateFormat('h:mm a').format(event.date),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: event.location,
                  maxWidth: true,
                ),
                const SizedBox(height: 12),
                // RSVP badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: event.isGoing
                            ? AppColors.emerald.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.isGoing
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 14,
                            color: event.isGoing
                                ? AppColors.emerald
                                : Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            event.isGoing ? 'Going' : 'Not Going',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: event.isGoing
                                  ? AppColors.emerald
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.violet.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Delete this event permanently?'),
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
    if (confirm == true) {
      await ref.read(eventRepositoryProvider).deleteEvent(event.id);
    }
  }
}

class _StatusDot extends StatelessWidget {
  final bool isUpcoming;
  const _StatusDot({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isUpcoming ? AppColors.emerald : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isUpcoming ? 'Upcoming' : 'Completed',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isUpcoming ? AppColors.emerald : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool maxWidth;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.maxWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: maxWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.4)),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return maxWidth ? child : child;
  }
}