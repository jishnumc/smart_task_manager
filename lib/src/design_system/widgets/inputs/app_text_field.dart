import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';

/// Customized Text Input Field following Material 3 design system tokens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;

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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          maxLines: maxLines,
          onChanged: onChanged,
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
            suffixIcon: suffixIcon,
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
