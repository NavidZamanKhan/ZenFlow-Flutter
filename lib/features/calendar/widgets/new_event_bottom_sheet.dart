import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/calendar_item.dart';

class NewEventBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<CalendarItem> onEventCreated;

  const NewEventBottomSheet({
    super.key,
    required this.initialDate,
    required this.onEventCreated,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<CalendarItem> onEventCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewEventBottomSheet(
        initialDate: initialDate,
        onEventCreated: onEventCreated,
      ),
    );
  }

  @override
  State<NewEventBottomSheet> createState() => _NewEventBottomSheetState();
}

class _NewEventBottomSheetState extends State<NewEventBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  bool _isAllDay = false;
  CalendarItemType _selectedType = CalendarItemType.event;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final startDateTime = _isAllDay
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _startTime.hour,
            _startTime.minute,
          );

    final endDateTime = _isAllDay
        ? null
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _endTime.hour,
            _endTime.minute,
          );

    final newItem = CalendarItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isAllDay: _isAllDay,
      type: _selectedType,
      category: _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : 'General',
    );

    widget.onEventCreated(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: zen.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New event',
                  style: AppTextStyles.headingLarge(zen.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, size: 16, color: zen.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Title Field
            Text('Title', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _titleController,
              hintText: 'e.g. Weekly Strategy Sync',
            ),
            const SizedBox(height: 16),

            // Date Picker Button
            Text('Date', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: zen.subtleFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: zen.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: AppTextStyles.bodyMedium(zen.textPrimary),
                    ),
                    Icon(LucideIcons.calendar, size: 16, color: zen.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // All Day Switch Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All-day event', style: AppTextStyles.bodyMedium(zen.textPrimary)),
                Switch.adaptive(
                  value: _isAllDay,
                  activeTrackColor: zen.accent,
                  onChanged: (val) => setState(() => _isAllDay = val),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Start & End Time Pickers (if not all day)
            if (!_isAllDay) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Starts', style: AppTextStyles.labelSmall(zen.textMuted)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickStartTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: zen.subtleFill,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: zen.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startTime.format(context),
                                  style: AppTextStyles.bodyMedium(zen.textPrimary),
                                ),
                                Icon(LucideIcons.clock, size: 16, color: zen.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ends', style: AppTextStyles.labelSmall(zen.textMuted)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickEndTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: zen.subtleFill,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: zen.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endTime.format(context),
                                  style: AppTextStyles.bodyMedium(zen.textPrimary),
                                ),
                                Icon(LucideIcons.clock, size: 16, color: zen.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Type & Category Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 8) / 2;
                          final selectedIndex =
                              _selectedType == CalendarItemType.event ? 0 : 1;

                          return Container(
                            height: 42,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: zen.subtleFill,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: zen.border),
                            ),
                            child: Stack(
                              children: [
                                // Animated sliding background pill with micro-shadow
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutCubic,
                                  left: selectedIndex * itemWidth,
                                  top: 0,
                                  bottom: 0,
                                  width: itemWidth,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: zen.card,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: zen.isDark ? 0.25 : 0.06,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Interactive text targets
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _selectedType =
                                              CalendarItemType.event);
                                        },
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            style: AppTextStyles.labelSmall(
                                              _selectedType ==
                                                      CalendarItemType.event
                                                  ? zen.accent
                                                  : zen.textSecondary,
                                            ).copyWith(
                                              fontWeight: _selectedType ==
                                                      CalendarItemType.event
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                            child: const Text('Event'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => _selectedType =
                                              CalendarItemType.taskDeadline);
                                        },
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            style: AppTextStyles.labelSmall(
                                              _selectedType ==
                                                      CalendarItemType
                                                          .taskDeadline
                                                  ? zen.accent
                                                  : zen.textSecondary,
                                            ).copyWith(
                                              fontWeight: _selectedType ==
                                                      CalendarItemType
                                                          .taskDeadline
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                            child: const Text('Deadline'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      ZenTextField(
                        controller: _categoryController,
                        hintText: 'e.g. Work, Social',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text('Notes (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _descriptionController,
              hintText: 'Add details, location, or notes...',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: AppTextStyles.labelMedium(zen.textMuted)),
                ),
                const SizedBox(width: 12),
                ZenButton(
                  label: 'Create event',
                  height: 42,
                  width: 135,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
