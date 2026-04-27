// lib/presentation/events/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/connectivity_service.dart';
import '../widgets/event_card.dart';
import '../widgets/shimmer_card.dart';

// ─── Filter State ─────────────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String>((ref) => 'All');
final statusFilterProvider = StateProvider<String>((ref) => 'All');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(userEventsStreamProvider);
    final query = ref.watch(searchQueryProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final user = ref.watch(currentUserProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user?.displayName ?? 'there'),
            if (!isOnline) _buildOfflineBanner(),
            _buildSearchBar(),
            _buildCategoryChips(),
            _buildStatusTabs(),
            Expanded(
              child: eventsAsync.when(
                data: (events) {
                  final filtered = EventRepository.applyFilters(
                    events: events,
                    query: query,
                    categoryFilter: categoryFilter,
                    statusFilter: statusFilter,
                  );
                  if (filtered.isEmpty) return _buildEmptyState();
                  return _buildEventList(filtered);
                },
                loading: () => _buildShimmerList(),
                error: (e, _) => _buildErrorState(e),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.createEventRoute),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Event'),
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, ${name.split(' ').first} 👋',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        )),
                Text('Your Events',
                    style: Theme.of(context).textTheme.displayMedium),
              ],
            ),
          ),
          // Theme toggle
          Consumer(builder: (_, ref, __) {
            final themeMode = ref.watch(themeModeProvider);
            return IconButton(
              onPressed: () =>
                  ref.read(themeModeProvider.notifier).toggle(),
              icon: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: AppColors.violet,
              ),
            );
          }),
          // Profile
          GestureDetector(
            onTap: () => context.push(AppConstants.profileRoute),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.violet.withOpacity(0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'E',
                style: const TextStyle(
                  color: AppColors.violet,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.amber),
          SizedBox(width: 8),
          Text(
            'You\'re offline — showing cached data',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) =>
            ref.read(searchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Search events or locations...',
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.violet),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildCategoryChips() {
    final selected = ref.watch(categoryFilterProvider);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          final isSelected = cat == selected;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(categoryFilterProvider.notifier).state = cat,
            selectedColor: AppColors.violet.withOpacity(0.15),
            checkmarkColor: AppColors.violet,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.violet : null,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildStatusTabs() {
    final selected = ref.watch(statusFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: AppConstants.statusFilters.map((s) {
          final isSelected = s == selected;
          return GestureDetector(
            onTap: () =>
                ref.read(statusFilterProvider.notifier).state = s,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.violet
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.violet
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEventList(List<EventModel> events) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: events.length,
      itemBuilder: (_, i) {
        return EventCard(event: events[i])
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: 5,
      itemBuilder: (_, i) => const ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.violet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              size: 52,
              color: AppColors.violet,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search\nor create a new event!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }


  Widget _buildErrorState(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.rose),
            const SizedBox(height: 16),
            Text('Failed to load events',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(e.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}