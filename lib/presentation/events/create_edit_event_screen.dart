// lib/presentation/events/create_edit_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';
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
        );
        await repo.updateEvent(updated);
      } else {
        await repo.createEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          date: _selectedDate!,
          location: _locationCtrl.text.trim(),
          category: _selectedCategory,
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
                const SizedBox(height: 20),

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
}