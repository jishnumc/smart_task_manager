import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/widgets.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('All Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Simulate Skeleton Loading',
            onPressed: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
          ),
        ],
      ),
      body: Skeletonizer(
        enabled: _isLoading,
        child: _isLoading
            ? ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  return AppCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.primary,
                        child: const Icon(Icons.task, color: Colors.white),
                      ),
                      title: const Text('Skeleton Task Title Item'),
                      subtitle: const Text('High Priority • Due in 2 days'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: colors.subText.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No Tasks Available',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: colors.mainText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your task list will appear here',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.subText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
