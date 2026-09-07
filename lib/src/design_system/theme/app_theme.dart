import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/colors/app_colours.dart';
import 'package:smart_task_manager/src/design_system/typography/app_text_theme.dart';


/// {@template app_theme}
/// The base theme for the application.
/// {@endtemplate}
abstract class AppTheme {
  /// {@macro app_theme}
  const AppTheme({required this.colors, required this.textTheme});

  /// The colors for this theme.
  final AppColors colors;

  /// The text theme for this theme.
  final AppTextTheme textTheme;

  /// Returns the [ThemeData] for this theme.
  ThemeData get themeData;
}