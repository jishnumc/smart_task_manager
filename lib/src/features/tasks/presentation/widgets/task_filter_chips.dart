import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/features/tasks/data/task_options_data.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_filter_enums.dart';

class TaskFilterChips extends StatelessWidget {
  const TaskFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.selectedCategory,
    required this.onCategorySelected,
    this.selectedPriority,
    required this.onPrioritySelected,
    required this.onOpenSortModal,
  });

  final TaskStatusFilter selectedStatus;
  final ValueChanged<TaskStatusFilter> onStatusSelected;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;
  final String? selectedPriority;
  final ValueChanged<String?> onPrioritySelected;
  final VoidCallback onOpenSortModal;

  void _showFilterModal(BuildContext context) {
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: colors.surface,
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Tasks',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.mainText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onCategorySelected(null);
                      onPrioritySelected(null);
                      Navigator.of(modalContext).pop();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Category',
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.subText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  'All',
                  ...TaskOptionsData.categories,
                ].map((cat) {
                  final isSel = (cat == 'All' && selectedCategory == null) ||
                      selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    onSelected: (val) {
                      onCategorySelected(cat == 'All' ? null : cat);
                      Navigator.of(modalContext).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Priority',
                style: context.textTheme.labelMedium?.copyWith(
                  color: colors.subText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  'All',
                  ...TaskOptionsData.priorities,
                ].map((prio) {
                  final isSel = (prio == 'All' && selectedPriority == null) ||
                      selectedPriority == prio;
                  return ChoiceChip(
                    label: Text(prio),
                    selected: isSel,
                    onSelected: (val) {
                      onPrioritySelected(prio == 'All' ? null : prio);
                      Navigator.of(modalContext).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final hasExtraFilters = selectedCategory != null || selectedPriority != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...TaskStatusFilter.values.map((filter) {
            final isSelected = selectedStatus == filter;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: isSelected,
                selectedColor: colors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? colors.primary : colors.mainText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => onStatusSelected(filter),
              ),
            );
          }),
          const SizedBox(width: AppSpacing.xs),
          ActionChip(
            avatar: Icon(
              Icons.filter_list_rounded,
              size: 16,
              color: hasExtraFilters ? colors.primary : colors.subText,
            ),
            label: Text(
              hasExtraFilters ? 'Filtered' : 'Filter',
              style: TextStyle(
                color: hasExtraFilters ? colors.primary : colors.mainText,
                fontWeight: hasExtraFilters ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onPressed: () => _showFilterModal(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          ActionChip(
            avatar: Icon(
              Icons.sort_rounded,
              size: 16,
              color: colors.subText,
            ),
            label: const Text('Sort'),
            onPressed: onOpenSortModal,
          ),
        ],
      ),
    );
  }
}
