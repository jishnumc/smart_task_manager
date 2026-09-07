import 'package:flutter/material.dart';

/// {@template app_text_theme}
/// The typography theme for the application.
/// {@endtemplate}
abstract class AppTextTheme {
  /// {@macro app_text_theme}
  const AppTextTheme();

  /// The text theme data.
  TextTheme get data;

  /// Large display text style.
  TextStyle get displayLarge;

  /// Medium display text style.
  TextStyle get displayMedium;

  /// Small display text style.
  TextStyle get displaySmall;

  /// Large headline text style.
  TextStyle get headlineLarge;

  /// Medium headline text style.
  TextStyle get headlineMedium;

  /// Small headline text style.
  TextStyle get headlineSmall;

  /// Large title text style.
  TextStyle get titleLarge;

  /// Medium title text style.
  TextStyle get titleMedium;

  /// Small title text style.
  TextStyle get titleSmall;

  /// Large body text style.
  TextStyle get bodyLarge;

  /// Medium body text style.
  TextStyle get bodyMedium;

  /// Small body text style.
  TextStyle get bodySmall;

  /// Large label text style.
  TextStyle get labelLarge;

  /// Medium label text style.
  TextStyle get labelMedium;

  /// Small label text style.
  TextStyle get labelSmall;
}
