import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/typography/app_text_theme.dart';



/// {@template text_theme_native}
/// Native text theme implementation.
///
/// Provides text styles optimized for mobile (iOS/Android) platforms,
/// typically using platform-default font weights and spacing.
/// {@endtemplate}

/// {@template mobile_text_theme}
/// The text theme for mobile devices.
/// {@endtemplate}
class TextThemeNative extends AppTextTheme {
  /// {@macro mobile_text_theme}
  const TextThemeNative();

  @override
  TextTheme get data => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  @override
  TextStyle get displayLarge => const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12, // 64 / 57
    letterSpacing: -0.25,
  );

  @override
  TextStyle get displayMedium => const TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16, // 52 / 45
    letterSpacing: 0,
  );

  @override
  TextStyle get displaySmall => const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22, // 44 / 36
    letterSpacing: 0,
  );

  @override
  TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.25, // 40 / 32
    letterSpacing: 0,
  );

  @override
  TextStyle get headlineMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.29, // 36 / 28
    letterSpacing: 0,
  );

  @override
  TextStyle get headlineSmall => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.33, // 32 / 24
    letterSpacing: 0,
  );

  @override
  TextStyle get titleLarge => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.27, // 28 / 22
    letterSpacing: 0,
  );

  @override
  TextStyle get titleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5, // 24 / 16
    letterSpacing: 0.15,
  );

  @override
  TextStyle get titleSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43, // 20 / 14
    letterSpacing: 0.1,
  );

  @override
  TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5, // 24 / 16
    letterSpacing: 0.5,
  );

  @override
  TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43, // 20 / 14
    letterSpacing: 0.25,
  );

  @override
  TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33, // 16 / 12
    letterSpacing: 0.4,
  );

  @override
  TextStyle get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43, // 20 / 14
    letterSpacing: 0.1,
  );

  @override
  TextStyle get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33, // 16 / 12
    letterSpacing: 0.5,
  );

  @override
  TextStyle get labelSmall => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45, // 16 / 11
    letterSpacing: 0.5,
  );
}
