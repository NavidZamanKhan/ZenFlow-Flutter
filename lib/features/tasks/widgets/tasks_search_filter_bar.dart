import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/task_filter.dart';
import 'tasks_status_segmented_bar.dart';

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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return const Color(0xFF8B5CF6);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'family':
        return const Color(0xFFF59E0B);
      case 'work':
        return const Color(0xFF10B981);
      case 'meetings':
        return const Color(0xFF6366F1);
      case 'finance':
        return const Color(0xFF14B8A6);
      case 'general':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Input Field
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

        // 2. Apple / Linear Solid Segmented Track [ All | Pending | Overdue | Completed ]
        TasksStatusSegmentedBar(
          selectedStatus: selectedStatus,
          onStatusChanged: onStatusSelected,
        ),
        const SizedBox(height: 12),

        // 3. Category Filter Chips with Color Dots
        if (categories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isAll = cat == 'All';
                final isSelected =
                    (selectedCategory == null && isAll) || (selectedCategory == cat);
                final catColor = _getCategoryColor(cat);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onCategorySelected(isAll ? null : cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6.5,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (zen.isDark ? zen.accentSoft : zen.accentLightBg)
                            : zen.subtleFill,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? zen.accent
                              : zen.border.withValues(alpha: 0.6),
                          width: isSelected ? 1.2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isAll) ...[
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                color: catColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat,
                            style: AppTextStyles.labelSmall(
                              isSelected ? zen.accent : zen.textSecondary,
                            ).copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
