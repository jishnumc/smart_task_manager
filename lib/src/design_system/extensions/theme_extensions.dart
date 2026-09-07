import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/colors/app_colours.dart';

/// Extension methods for easy access to theme tokens via BuildContext.
extension ThemeBuildContextX on BuildContext {
  /// Returns the custom [AppColors] theme extension.
  AppColors get appColors {
    final colors = Theme.of(this).extension<AppColors>();
    if (colors == null) {
      throw StateError(
        'AppColors extension was not found in ThemeData. '
        'Ensure AppColors is added to ThemeData.extensions.',
      );
    }
    return colors;
  }

  /// Returns the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns true if current brightness is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
