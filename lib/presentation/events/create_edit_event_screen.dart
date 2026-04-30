// lib/presentation/events/create_edit_event_screen.dart
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
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';

class CreateEditEventScreen extends ConsumerStatefulWidget {
  final EventModel? event; // null = create, non-null = edit

  const CreateEditEventScreen({super.key, this.event});

  @override
  ConsumerState<CreateEditEventScreen> createState() =>
      _CreateEditEventScreenState();
}

class _CreateEditEventScreenState
    extends ConsumerState<CreateEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;

  DateTime? _selectedDate;
  String _selectedCategory = AppConstants.categories[1]; // skip 'All'
  bool _loading = false;
  bool _isPublic = true;
  List<String> _invitedUserIds = [];
  List<UserModel>? _availableUsers;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _selectedDate = e?.date;
    _selectedCategory = e?.category ?? AppConstants.categories[1];
    _isPublic = e?.isPublic ?? true;
    _invitedUserIds = e?.invitedUserIds ?? [];
    _loadAvailableUsers();
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snap = await firestore.collection('users').get();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final users = snap.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() => _availableUsers = users);
      }
    } catch (e) {
      if (mounted) print('[v0] Error loading users: $e');
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.violet),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    // Pick time too
    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.violet),
        ),
        child: child!,
      ),
    );

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime?.hour ?? 12,
        pickedTime?.minute ?? 0,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _errorSnack('Please select a date and time'),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(eventRepositoryProvider);

      if (_isEditing) {
        final updated = widget.event!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate,
          location: _locationCtrl.text.trim(),
          category: _selectedCategory,
          isPublic: _isPublic,
          invitedUserIds: _invitedUserIds,
        );
        await repo.updateEvent(updated);
      } else {
        await repo.createEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate!,
          location: _locationCtrl.text.trim(),
          category: _selectedCategory,
          isPublic: _isPublic,
          invitedUserIds: _invitedUserIds,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Event updated! ✅' : 'Event created! 🎉'),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_errorSnack('Failed: ${e.toString()}'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  SnackBar _errorSnack(String msg) => SnackBar(
    content: Text(msg),
    backgroundColor: AppColors.rose,
    behavior: SnackBarBehavior.floating,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Edit Event' : 'New Event'),
        actions: _isEditing
            ? [
          IconButton(
            icon:
            const Icon(Icons.delete_outline_rounded, color: AppColors.rose),
            onPressed: _confirmDelete,
          ),
        ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Event Title',
                  hint: 'What\'s happening?',
                  prefixIcon: Icons.title_rounded,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Title is required';
                    if (v.length < 3) return 'Title is too short';
                    return null;
                  },
                ).animate().fadeIn(delay: 50.ms),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  hint: 'Tell people what this event is about...',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Description is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationCtrl,
                  label: 'Location',
                  hint: 'Where is this happening?',
                  prefixIcon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Location is required';
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 16),

                // Date Picker
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.violet, size: 20),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Select date & time'
                                : DateFormat('EEE, MMM d, yyyy • h:mm a')
                                .format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedDate == null
                                  ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),

                // Privacy Section Header
                Text('Privacy Settings',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Public/Private Toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isPublic
                            ? Icons.public_rounded
                            : Icons.lock_rounded,
                        color: AppColors.violet,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPublic ? 'Public Event' : 'Private Event',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _isPublic
                                  ? 'Everyone can see this event'
                                  : 'Only invited people can see this',
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
                      Switch(
                        value: _isPublic,
                        onChanged: (value) =>
                            setState(() => _isPublic = value),
                        activeColor: AppColors.violet,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms),

                // Invite Users Section
                if (!_isPublic)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite People',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showInviteModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_add_rounded,
                                    color: AppColors.violet, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _invitedUserIds.isEmpty
                                        ? 'Add people to invite'
                                        : '${_invitedUserIds.length} person${_invitedUserIds.length > 1 ? 's' : ''} invited',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _invitedUserIds.isEmpty
                                          ? Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.5)
                                          : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 20),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 275.ms),
                        if (_invitedUserIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _invitedUserIds.asMap().entries.map((e) {
                                final userId = e.value;
                                final user = _availableUsers
                                    ?.firstWhere(
                                      (u) => u.id == userId,
                                  orElse: () =>
                                      UserModel(
                                        id: userId,
                                        name: 'Unknown User',
                                        email: '',
                                        createdAt: DateTime.now(),
                                      ),
                                );
                                return Chip(
                                  avatar: Icon(Icons.person_rounded, size: 16),
                                  label: Text(user?.name ?? 'Unknown'),
                                  onDeleted: () {
                                    setState(() {
                                      _invitedUserIds.removeAt(e.key);
                                    });
                                  },
                                  backgroundColor:
                                  AppColors.violet.withOpacity(0.1),
                                  labelStyle: const TextStyle(
                                    color: AppColors.violet,
                                    fontSize: 13,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 280.ms),

                const SizedBox(height: 28),

                // Category selector
                Text('Category',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 13)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categories
                      .where((c) => c != 'All')
                      .map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.violet
                              : Theme.of(context)
                              .cardTheme
                              .color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.violet
                                : Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 40),
                GradientButton(
                  label: _isEditing ? 'Save Changes' : 'Create Event 🎉',
                  loading: _loading,
                  onTap: _submit,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
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
            'Are you sure you want to delete this event? This cannot be undone.'),
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
      await ref
          .read(eventRepositoryProvider)
          .deleteEvent(widget.event!.id);
      if (mounted) context.go(AppConstants.homeRoute);
    }
  }

  void _showInviteModal() {
    final searchCtrl = TextEditingController();
    final selected = Set<String>.from(_invitedUserIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = (_availableUsers ?? [])
              .where((u) =>
          u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query))
              .toList();

          return Container(
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invite People',
                          style: Theme.of(ctx)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name or email...',
                        prefixIcon:
                        const Icon(Icons.search_rounded, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),

                  // User list
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(
                            color: Theme.of(ctx)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final user = filtered[idx];
                        final isSelected = selected.contains(user.id);

                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) {
                            setState(() {
                              if (isSelected) {
                                selected.remove(user.id);
                              } else {
                                selected.add(user.id);
                              }
                            });
                          },
                          title: Text(user.name),
                          subtitle: Text(user.email, maxLines: 1),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _invitedUserIds = selected.toList();
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Invitations',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
