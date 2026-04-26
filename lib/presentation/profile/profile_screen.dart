// lib/presentation/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userProfile = ref.watch(userProfileProvider);
    final eventsAsync = ref.watch(userEventsStreamProvider);
    final themeMode = ref.watch(themeModeProvider);

    final name = user?.displayName ?? 'Eventora User';
    final email = user?.email ?? '';
    final initials =
        name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.violet, AppColors.violetLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(name, style: Theme.of(context).textTheme.headlineMedium)
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 4),
              Text(email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14))
                  .animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 8),
              userProfile.when(
                data: (profile) => profile != null
                    ? Text(
                        'Member since ${DateFormat('MMM yyyy').format(profile.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Stats Row
              eventsAsync.when(
                data: (events) {
                  final upcoming = events.where((e) => e.isUpcoming).length;
                  final going = events.where((e) => e.isGoing).length;
                  return _StatsRow(
                    total: events.length,
                    upcoming: upcoming,
                    going: going,
                  ).animate().fadeIn(delay: 200.ms);
                },
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              // Settings Tiles
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  activeColor: AppColors.violet,
                ),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 1),
              _SettingsTile(
                icon: Icons.event_note_rounded,
                label: 'My Events',
                onTap: () {
                  context.pop();
                },
                trailing: const Icon(Icons.chevron_right_rounded),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.rose),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                        color: AppColors.rose, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: AppColors.rose.withOpacity(0.5), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: AppColors.rose)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authServiceProvider).logout();
      if (context.mounted) context.go(AppConstants.loginRoute);
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int total;
  final int upcoming;
  final int going;

  const _StatsRow(
      {required this.total, required this.upcoming, required this.going});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Total Events', value: '$total', icon: '📅'),
        const SizedBox(width: 12),
        _StatCard(label: 'Upcoming', value: '$upcoming', icon: '🟢'),
        const SizedBox(width: 12),
        _StatCard(label: "I'm Going", value: '$going', icon: '🎉'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.violet,
                    )),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.violet, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}