import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/widgets.dart';
import 'package:smart_task_manager/src/features/tasks/data/task_options_data.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_notifier.dart';
import 'package:smart_task_manager/src/features/tasks/presentation/notifiers/create_task_state.dart';
import 'package:smart_task_manager/src/system/exceptions/app_exception.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _priorities = [];
  List<String> _categories = [];

  String? _selectedPriority;
  String? _selectedCategory;
  DateTime _dueDate = DateTime(2026, 9, 7, 19, 14, 6);
  final bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadTaskOptionsData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTaskOptionsData() {
    final priorities = TaskOptionsData.priorities;
    final categories = TaskOptionsData.categories;

    _priorities = priorities;
    _categories = categories;
    _selectedPriority = priorities.contains('Medium')
        ? 'Medium'
        : (priorities.isNotEmpty ? priorities.first : null);
    _selectedCategory = categories.contains('Work')
        ? 'Work'
        : (categories.isNotEmpty ? categories.first : null);
  }

  void _fillSampleData() {
    final sample = TaskOptionsData.sampleTask;
    setState(() {
      _titleController.text = sample['title'] as String? ?? 'Buy Groceries';
      _descriptionController.text =
          sample['description'] as String? ?? 'Milk, Bread, Eggs, Vegetables';
      if (sample['due_date'] != null) {
        _dueDate = DateTime.tryParse(sample['due_date'] as String) ??
            DateTime(2026, 9, 7, 19, 14, 6);
      }
      final samplePriority = sample['priority'] as String?;
      final sampleCategory = sample['category'] as String?;
      if (samplePriority != null && _priorities.contains(samplePriority)) {
        _selectedPriority = samplePriority;
      }
      if (sampleCategory != null && _categories.contains(sampleCategory)) {
        _selectedCategory = sampleCategory;
      }
    });
  }

  String _formatDisplayDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    return '$d/$m/$y';
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _dueDate.hour,
            _dueDate.minute,
          );
        });
      }
    }
  }

  void _submitTask() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(createTaskProvider.notifier).submitTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            isCompleted: _isCompleted,
            dueDate: _dueDate,
            priority: _selectedPriority ?? 'Medium',
            category: _selectedCategory ?? 'Work',
          );
    }
  }

  void _handleStateChange(CreateTaskState? previous, CreateTaskState next) {
    next.whenOrNull(
      success: (task, isOfflineSaved) {
        final colors = context.appColors;
        final message = isOfflineSaved
            ? 'Network offline! Task saved locally to SQLite DB.'
            : 'Task created successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isOfflineSaved
                      ? Icons.wifi_off_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor:
                isOfflineSaved ? Colors.orange.shade700 : colors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        if (mounted) {
          context.pop();
        }
      },
      error: (exception) {
        _showErrorDialog(exception);
      },
    );
  }

  void _showErrorDialog(AppException exception) {
    final colors = context.appColors;
    String title = 'Error';
    IconData icon = Icons.error_outline_rounded;
    Color iconColor = colors.error;

    if (exception is NetworkException) {
      title = 'Network Error';
      icon = Icons.wifi_off_rounded;
      iconColor = Colors.orange;
    } else if (exception is ServerException) {
      title = 'Server Error';
      icon = Icons.cloud_off_rounded;
      iconColor = colors.error;
    } else if (exception is CacheException) {
      title = 'Database Error';
      icon = Icons.storage_rounded;
      iconColor = colors.error;
    } else if (exception is AuthException) {
      title = 'Authentication Error';
      icon = Icons.lock_clock_rounded;
      iconColor = colors.error;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: colors.mainText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            exception.message,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.subText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: colors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CreateTaskState>(
      createTaskProvider,
      _handleStateChange,
    );

    final createTaskState = ref.watch(createTaskProvider);
    final isLoading = createTaskState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Create Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded),
            tooltip: 'Fill Sample Data',
            onPressed: isLoading ? null : _fillSampleData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Task Details',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: isLoading ? null : _fillSampleData,
                          icon: const Icon(Icons.flash_on_rounded, size: 18),
                          label: const Text('Fill Sample'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Title',
                      controller: _titleController,
                      hintText: 'e.g. Buy Groceries',
                      prefixIcon: Icons.task_alt_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      hintText: 'e.g. Milk, Bread, Eggs, Vegetables',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdownField<String>(
                      label: 'Priority',
                      value: _selectedPriority,
                      hintText: 'Select priority',
                      prefixIcon: Icons.flag_rounded,
                      items: _priorities
                          .map(
                            (priority) => DropdownMenuItem(
                              value: priority,
                              child: Text(priority),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedPriority = val);
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please select a priority';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDropdownField<String>(
                      label: 'Category',
                      value: _selectedCategory,
                      hintText: 'Select category',
                      prefixIcon: Icons.category_rounded,
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedCategory = val);
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Due Date Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InkWell(
                          onTap: isLoading ? null : _selectDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: colors.optionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20,
                                  color: colors.subText,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _formatDisplayDate(_dueDate),
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(color: colors.mainText),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: colors.subText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryButton(
                      text: 'Create Task',
                      icon: Icons.save_rounded,
                      isLoading: isLoading,
                      onPressed: _submitTask,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
