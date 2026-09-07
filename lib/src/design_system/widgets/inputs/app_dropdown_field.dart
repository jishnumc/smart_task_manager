import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

/// Customized Dropdown Input Field following Material 3 design system tokens.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? hintText;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: colors.mainText,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          initialValue: value,

          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.subText,
          ),
          dropdownColor: colors.surface,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.mainText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: colors.subText,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: colors.subText)
                : null,
            filled: true,
            fillColor: colors.optionBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
