import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/secondary_button.dart';

class TaskListEmptyView extends StatelessWidget {
  const TaskListEmptyView({
    super.key,
    required this.isFiltered,
    required this.onResetFilters,
  });

  final bool isFiltered;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFiltered
                      ? Icons.filter_alt_off_rounded
                      : Icons.assignment_outlined,
                  size: 72,
                  color: colors.subText.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isFiltered ? 'No Tasks Match Filters' : 'No Tasks Available',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: colors.mainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isFiltered
                      ? 'Try clearing your search query or adjusting your status filters.'
                      : 'Create your first task to get started',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.subText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isFiltered)
                  SecondaryButton(
                    text: 'Clear Search & Filters',
                    icon: Icons.refresh_rounded,
                    onPressed: onResetFilters,
                  )
                else
                  PrimaryButton(
                    text: 'Create New Task',
                    fullWidth: false,
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/create-task'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
