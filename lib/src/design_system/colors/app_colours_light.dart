import 'package:flutter/material.dart';

import 'app_colours.dart';

/// {@template app_colors_light}
/// The light theme color palette.
/// {@endtemplate}
class AppColorsLight extends AppColors {
  /// {@macro app_colors_light}
  const AppColorsLight()
    : super(
        primary: const Color(0xFF6750A4),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFEADDFF),
        onPrimaryContainer: const Color(0xFF21005D),
        secondary: const Color(0xFF625B71),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFFE8DEF8),
        onSecondaryContainer: const Color(0xFF1D192B),
        error: const Color(0xFFB3261E),
        onError: const Color(0xFFFFFFFF),
        surface: const Color(0xFFFFFBFE),
        onSurface: const Color(0xFF1C1B1F),
        outline: const Color(0xFF79747E),
        quizBackground: const Color(0xFF3884FD),
        quizCardBg: Colors.white,
        bannerBg: Colors.white,
        bannerText: const Color(0xFFF35C5C),
        mainText: const Color(0xFF333333),
        subText: const Color(0xFF444444),
        questionBoxBg: const Color(0xFFF8FAFF),
        questionBoxBorder: const Color(0xFFC2D6FF),
        optionBg: Colors.white,
        optionBorder: const Color(0xFFEEEEEE),
        dividerColor: const Color(0xFFEEEEEE),
      );
}