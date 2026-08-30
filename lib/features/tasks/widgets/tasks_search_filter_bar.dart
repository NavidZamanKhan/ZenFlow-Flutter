import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/task_filter.dart';

class TasksSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final TaskStatusFilter selectedStatus;
  final ValueChanged<TaskStatusFilter> onStatusSelected;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const TasksSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Field
        ZenTextField(
          controller: searchController,
          hintText: 'Search tasks...',
          prefixIcon: Icon(LucideIcons.search, size: 18, color: zen.textMuted),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(LucideIcons.x, size: 16, color: zen.textMuted),
                  onPressed: () {
                    searchController.clear();
                    onClearSearch();
                  },
                )
              : null,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Status Filter Pills (Horizontal scrolling)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _StatusPill(
                label: 'All',
                isSelected: selectedStatus == TaskStatusFilter.all,
                onTap: () => onStatusSelected(TaskStatusFilter.all),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: 'Pending',
                isSelected: selectedStatus == TaskStatusFilter.pending,
                onTap: () => onStatusSelected(TaskStatusFilter.pending),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: 'Overdue',
                isSelected: selectedStatus == TaskStatusFilter.overdue,
                onTap: () => onStatusSelected(TaskStatusFilter.overdue),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: 'Completed',
                isSelected: selectedStatus == TaskStatusFilter.completed,
                onTap: () => onStatusSelected(TaskStatusFilter.completed),
              ),
              const SizedBox(width: 12),

              // Category Divider
              Container(
                width: 1,
                height: 20,
                color: zen.border,
              ),
              const SizedBox(width: 12),

              // Category Pills
              ...categories.map((cat) {
                final isSelected = (selectedCategory == null && cat == 'All') ||
                    (selectedCategory == cat);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryPill(
                    label: cat,
                    isSelected: isSelected,
                    onTap: () => onCategorySelected(cat == 'All' ? null : cat),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? zen.accent : zen.subtleFill,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? zen.accent : zen.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            isSelected ? Colors.white : zen.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? (zen.isDark ? zen.accentSoft : zen.accentLightBg) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? zen.accent : zen.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            isSelected ? zen.accent : zen.textMuted,
          ),
        ),
      ),
    );
  }
}
