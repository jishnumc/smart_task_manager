import 'package:flutter/material.dart';

/// {@template app_colors}
/// The color palette for the application, extending [ThemeExtension].
/// Contains core Material 3 colors, excluding rarely used variants.
/// {@endtemplate}
class AppColors extends ThemeExtension<AppColors> {
  /// {@macro app_colors}
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.error,
    required this.onError,
    required this.surface,
    required this.onSurface,
    required this.outline,
    required this.quizBackground,
    required this.quizCardBg,
    required this.bannerBg,
    required this.bannerText,
    required this.mainText,
    required this.subText,
    required this.questionBoxBg,
    required this.questionBoxBorder,
    required this.optionBg,
    required this.optionBorder,
    required this.dividerColor,
  });

  /// The primary color.
  final Color primary;

  /// The on-primary color.
  final Color onPrimary;

  /// The primary container color.
  final Color primaryContainer;

  /// The on-primary container color.
  final Color onPrimaryContainer;

  /// The secondary color.
  final Color secondary;

  /// The on-secondary color.
  final Color onSecondary;

  /// The secondary container color.
  final Color secondaryContainer;

  /// The on-secondary container color.
  final Color onSecondaryContainer;

  /// The error color.
  final Color error;

  /// The on-error color.
  final Color onError;

  /// The surface color.
  final Color surface;

  /// The on-surface color.
  final Color onSurface;

  /// The outline color.
  final Color outline;

  /// Quiz UI Background color
  final Color quizBackground;

  /// Quiz Main Card Background color
  final Color quizCardBg;

  /// Quiz Header Banner Background color
  final Color bannerBg;

  /// Quiz Header Banner Text color
  final Color bannerText;

  /// Quiz General Text color
  final Color mainText;

  /// Quiz Sub/Description Text color
  final Color subText;

  /// Quiz Question Box Background color
  final Color questionBoxBg;

  /// Quiz Question Box Border color
  final Color questionBoxBorder;

  /// Quiz Option Card Background color
  final Color optionBg;

  /// Quiz Option Card Border color
  final Color optionBorder;

  /// Quiz Divider/Border color
  final Color dividerColor;

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? error,
    Color? onError,
    Color? surface,
    Color? onSurface,
    Color? outline,
    Color? quizBackground,
    Color? quizCardBg,
    Color? bannerBg,
    Color? bannerText,
    Color? mainText,
    Color? subText,
    Color? questionBoxBg,
    Color? questionBoxBorder,
    Color? optionBg,
    Color? optionBorder,
    Color? dividerColor,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      outline: outline ?? this.outline,
      quizBackground: quizBackground ?? this.quizBackground,
      quizCardBg: quizCardBg ?? this.quizCardBg,
      bannerBg: bannerBg ?? this.bannerBg,
      bannerText: bannerText ?? this.bannerText,
      mainText: mainText ?? this.mainText,
      subText: subText ?? this.subText,
      questionBoxBg: questionBoxBg ?? this.questionBoxBg,
      questionBoxBorder: questionBoxBorder ?? this.questionBoxBorder,
      optionBg: optionBg ?? this.optionBg,
      optionBorder: optionBorder ?? this.optionBorder,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      quizBackground: Color.lerp(quizBackground, other.quizBackground, t)!,
      quizCardBg: Color.lerp(quizCardBg, other.quizCardBg, t)!,
      bannerBg: Color.lerp(bannerBg, other.bannerBg, t)!,
      bannerText: Color.lerp(bannerText, other.bannerText, t)!,
      mainText: Color.lerp(mainText, other.mainText, t)!,
      subText: Color.lerp(subText, other.subText, t)!,
      questionBoxBg: Color.lerp(questionBoxBg, other.questionBoxBg, t)!,
      questionBoxBorder: Color.lerp(
        questionBoxBorder,
        other.questionBoxBorder,
        t,
      )!,
      optionBg: Color.lerp(optionBg, other.optionBg, t)!,
      optionBorder: Color.lerp(optionBorder, other.optionBorder, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }
}
