import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

class TaskSearchBar extends StatefulWidget {
  const TaskSearchBar({
    super.key,
    required this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  final ValueChanged<String> onSearchChanged;
  final Duration debounceDuration;

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(value);
    });
  }

  void _onClear() {
    _controller.clear();
    _debounceTimer?.cancel();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: context.textTheme.bodyMedium?.copyWith(
          color: colors.mainText,
        ),
        decoration: InputDecoration(
          hintText: 'Search tasks by title...',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: colors.subText,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.subText,
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.subText,
                    size: 18,
                  ),
                  onPressed: _onClear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
