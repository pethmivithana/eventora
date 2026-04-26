// lib/presentation/events/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late EventModel _event;
  bool _rsvpLoading = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _toggleRsvp() async {
    setState(() => _rsvpLoading = true);
    try {
      await ref
          .read(eventRepositoryProvider)
          .toggleRsvp(_event.id, _event.isGoing);
      setState(() {
        _event = _event.copyWith(isGoing: !_event.isGoing);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _rsvpLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = _event.isUpcoming;

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

                  // RSVP Section
                  _RsvpSection(
                    isGoing: _event.isGoing,
                    loading: _rsvpLoading,
                    onToggle: _toggleRsvp,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
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
      actions: [
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
  final bool isGoing;
  final bool loading;
  final VoidCallback onToggle;

  const _RsvpSection({
    required this.isGoing,
    required this.loading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isGoing
            ? AppColors.emerald.withOpacity(0.08)
            : AppColors.rose.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
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
                      'Your RSVP',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      isGoing ? 'You\'re going! 🎉' : 'Not going',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isGoing ? AppColors.emerald : AppColors.rose,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isGoing ? AppColors.rose : AppColors.emerald,
                foregroundColor: Colors.white,
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      isGoing ? "Change to Not Going" : "I'm Going! 🙋",
                    ),
            ),
          ),
        ],
      ),
    );
  }
}