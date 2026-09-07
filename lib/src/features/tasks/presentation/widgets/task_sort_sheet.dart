import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/task_filter_enums.dart';

class TaskSortSheet extends StatelessWidget {
  const TaskSortSheet({
    super.key,
    required this.selectedSort,
    required this.isAscending,
    required this.onSortSelected,
    required this.onToggleDirection,
  });

  final TaskSortBy selectedSort;
  final bool isAscending;
  final ValueChanged<TaskSortBy> onSortSelected;
  final VoidCallback onToggleDirection;

  static void show(
    BuildContext context, {
    required TaskSortBy selectedSort,
    required bool isAscending,
    required ValueChanged<TaskSortBy> onSortSelected,
    required VoidCallback onToggleDirection,
  }) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: context.appColors.surface,
      builder: (_) => TaskSortSheet(
        selectedSort: selectedSort,
        isAscending: isAscending,
        onSortSelected: onSortSelected,
        onToggleDirection: onToggleDirection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

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
                'Sort Tasks By',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.mainText,
                ),
              ),
              IconButton(
                icon: Icon(
                  isAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: colors.primary,
                ),
                tooltip: isAscending ? 'Ascending' : 'Descending',
                onPressed: () {
                  onToggleDirection();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...TaskSortBy.values.map((sortOption) {
            final isSelected = selectedSort == sortOption;
            return ListTile(
              title: Text(
                sortOption.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.mainText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Radio<TaskSortBy>(
                value: sortOption,
                groupValue: selectedSort,
                activeColor: colors.primary,
                onChanged: (val) {
                  if (val != null) {
                    onSortSelected(val);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                onSortSelected(sortOption);
                Navigator.of(context).pop();
              },
            );
          }),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
