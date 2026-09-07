import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/secondary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/inputs/app_dropdown_field.dart';
import 'package:smart_task_manager/src/design_system/widgets/inputs/app_text_field.dart';
import 'package:smart_task_manager/src/features/tasks/data/models/task_update_request_model.dart';
import 'package:smart_task_manager/src/features/tasks/data/task_options_data.dart';
import 'package:smart_task_manager/src/features/tasks/domain/entities/task_entity.dart';

class UpdateTaskBottomSheet extends StatefulWidget {
  const UpdateTaskBottomSheet({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  final TaskEntity task;
  final Future<bool> Function(TaskUpdateRequestModel payload) onUpdate;

  static void show(
    BuildContext context, {
    required TaskEntity task,
    required Future<bool> Function(TaskUpdateRequestModel payload) onUpdate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: context.appColors.surface,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: UpdateTaskBottomSheet(
          task: task,
          onUpdate: onUpdate,
        ),
      ),
    );
  }

  @override
  State<UpdateTaskBottomSheet> createState() => _UpdateTaskBottomSheetState();
}

class _UpdateTaskBottomSheetState extends State<UpdateTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late bool _isCompleted;
  late String _selectedPriority;
  late String _selectedCategory;
  late DateTime _dueDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _isCompleted = widget.task.isCompleted;
    _selectedPriority = TaskOptionsData.priorities.contains(widget.task.priority)
        ? widget.task.priority
        : TaskOptionsData.priorities.first;
    _selectedCategory = TaskOptionsData.categories.contains(widget.task.category)
        ? widget.task.category
        : TaskOptionsData.categories.first;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
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
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final payload = TaskUpdateRequestModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: _isCompleted,
      dueDate: _dueDate.toUtc().toIso8601String(),
      priority: _selectedPriority,
      category: _selectedCategory,
    );

    final success = await widget.onUpdate(payload);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Failed to update task. Please check your inputs.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Update Task',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.mainText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.subText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colors.error, fontSize: 13),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Is Completed Toggle Switch
            Container(
              decoration: BoxDecoration(
                color: colors.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                title: Text(
                  'Task Status',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.mainText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isCompleted ? 'Marked as Completed' : 'Marked as Pending',
                  style: TextStyle(
                    color: _isCompleted ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _isCompleted,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isCompleted = val),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title Input
            AppTextField(
              label: 'Title',
              hintText: 'Enter task title',
              controller: _titleController,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Title cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Description Input
            AppTextField(
              label: 'Description',
              hintText: 'Enter task description',
              controller: _descriptionController,
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.md),

            // Priority and Category Dropdowns
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Priority',
                    value: _selectedPriority,
                    items: TaskOptionsData.priorities.map((prio) {
                      return DropdownMenuItem(
                        value: prio,
                        child: Text(prio),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Category',
                    value: _selectedCategory,
                    items: TaskOptionsData.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Due Date Picker
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: colors.subText,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.subText,
                          ),
                        ),
                        Text(
                          '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')} ${_dueDate.hour.toString().padLeft(2, '0')}:${_dueDate.minute.toString().padLeft(2, '0')}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.edit_calendar_rounded, color: colors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons: Update and Back
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Back',
                    icon: Icons.arrow_back_rounded,
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: 'Update Task',
                    icon: Icons.check_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
