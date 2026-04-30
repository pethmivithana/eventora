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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchCtrl;
  late final AnimationController _headerAnimCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerAnimCtrl.dispose();
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
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.violet.withOpacity(0.05),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildCreativeHeader(context, user?.displayName ?? 'there'),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.createEventRoute),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Event'),
        backgroundColor: AppColors.violet,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildCreativeHeader(BuildContext context, String name) {
    final firstName = name.isNotEmpty ? name.split(' ').first : 'there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated greeting
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _headerAnimCtrl,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: Text(
                        'Hey, $firstName! 👋',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.violet,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.onSurface,
                            AppColors.violet,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Discover Amazing Events',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Theme toggle button
              Consumer(
                builder: (_, ref, __) {
                  final themeMode = ref.watch(themeModeProvider);
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _headerAnimCtrl,
                        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.violet.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.violet.withOpacity(0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        icon: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: AppColors.violet,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Profile button
              ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _headerAnimCtrl,
                    curve: Interval(0.4, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => context.push(AppConstants.profileRoute),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.violet.withOpacity(0.3),
                          AppColors.violetLight.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.violet.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.violet.withOpacity(0.15),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          color: AppColors.violet,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildOfflineBanner() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.amber.withOpacity(0.15),
                AppColors.rose.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.amber.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: AppColors.amber,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You\'re offline — showing cached data',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) =>
            ref.read(searchQueryProvider.notifier).state = v,
        decoration: InputDecoration(
          hintText: 'Search events, locations...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.violet, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.violet.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.violet.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: AppColors.violet.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.violet,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildCategoryChips() {
    final selected = ref.watch(categoryFilterProvider);
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = AppConstants.categories[i];
          final isSelected = cat == selected;

          return GestureDetector(
            onTap: () =>
                ref.read(categoryFilterProvider.notifier).state = cat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.violet,
                          AppColors.violetLight,
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : AppColors.violet.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.violet
                      : AppColors.violet.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ).animate(delay: Duration(milliseconds: i * 30)),
          );
        },
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildStatusTabs() {
    final selected = ref.watch(statusFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AppConstants.statusFilters.map((s) {
            final isSelected = s == selected;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () =>
                    ref.read(statusFilterProvider.notifier).state = s,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.violet : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.violet
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEventList(List<EventModel> events) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: events.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EventCard(event: events[i])
              .animate(delay: Duration(milliseconds: i * 50))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.15, end: 0),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerCard().animate().fadeIn(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.violet.withOpacity(0.2),
                    AppColors.violetLight.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.violet.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                size: 56,
                color: AppColors.violet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search or filters to discover amazing events!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  context.push(AppConstants.createEventRoute),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create an Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.85, 0.85)),
      ),
    );
  }

  Widget _buildErrorState(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.rose.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.rose,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
