import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/task_filter.dart';
import '../models/task_item.dart';
import 'priority_segmented_bar.dart';

class NewTaskBottomSheet extends StatefulWidget {
  final ValueChanged<TaskItem> onTaskCreated;

  const NewTaskBottomSheet({super.key, required this.onTaskCreated});

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<TaskItem> onTaskCreated,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewTaskBottomSheet(onTaskCreated: onTaskCreated),
    );
  }

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  TaskPriority _selectedPriority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date first.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedDueTime = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    String? normalizedTime;
    if (_selectedDueTime != null) {
      final h = _selectedDueTime!.hour.toString().padLeft(2, '0');
      final m = _selectedDueTime!.minute.toString().padLeft(2, '0');
      normalizedTime = '$h:$m';
    }

    final newTask = TaskItem(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate,
      dueTime: normalizedTime,
      priority: _selectedPriority,
      category: _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : 'General',
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    widget.onTaskCreated(newTask);
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
            // Modal Grab Handle
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

            // Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New task',
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
            const SizedBox(height: 20),

            // Task Title
            Text('Title', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _titleController,
              hintText: 'e.g. Finalize Q3 roadmap',
            ),
            const SizedBox(height: 16),

            // Description (Optional)
            Text('Description (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _descriptionController,
              hintText: 'Add details, links, or notes...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date & Due Time Pickers (Row)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due date (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
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
                                _selectedDueDate != null
                                    ? DateFormat('MM/dd/yyyy').format(_selectedDueDate!)
                                    : 'mm/dd/yyyy',
                                style: AppTextStyles.bodyMedium(
                                  _selectedDueDate != null ? zen.textPrimary : zen.textMuted,
                                ),
                              ),
                              Icon(LucideIcons.calendar, size: 16, color: zen.textMuted),
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
                      Text('Due time (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickTime,
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
                                _selectedDueTime != null
                                    ? _selectedDueTime!.format(context)
                                    : '10:30',
                                style: AppTextStyles.bodyMedium(
                                  _selectedDueTime != null ? zen.textPrimary : zen.textMuted,
                                ),
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

            // Priority Selector & Category Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Priority', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      PrioritySegmentedBar(
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: (p) => setState(() => _selectedPriority = p),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      ZenTextField(
                        controller: _categoryController,
                        hintText: 'e.g. Work, Design',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons (Cancel & Create Task)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: AppTextStyles.labelMedium(zen.textMuted)),
                ),
                const SizedBox(width: 12),
                ZenButton(
                  label: 'Create task',
                  height: 42,
                  width: 130,
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
