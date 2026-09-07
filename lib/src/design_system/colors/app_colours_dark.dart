import 'package:flutter/material.dart';

import 'app_colours.dart';

/// {@template app_colors_dark}
/// The dark theme color palette.
/// {@endtemplate}
class AppColorsDark extends AppColors {
  /// {@macro app_colors_dark}
  const AppColorsDark()
    : super(
        primary: const Color(0xFFD0BCFF),
        onPrimary: const Color(0xFF381E72),
        primaryContainer: const Color(0xFF4F378B),
        onPrimaryContainer: const Color(0xFFEADDFF),
        secondary: const Color(0xFFCCC2DC),
        onSecondary: const Color(0xFF332D41),
        secondaryContainer: const Color(0xFF4A4458),
        onSecondaryContainer: const Color(0xFFE8DEF8),
        error: const Color(0xFFF2B8B5),
        onError: const Color(0xFF601410),
        surface: const Color(0xFF1C1B1F),
        onSurface: const Color(0xFFE6E1E5),
        outline: const Color(0xFF938F99),
        quizBackground: const Color(0xFF0F172A),
        quizCardBg: const Color(0xFF1E293B),
        bannerBg: const Color(0xFF1E293B),
        bannerText: const Color(0xFFFFA3A3),
        mainText: const Color(0xFFF1F5F9),
        subText: const Color(0xFF94A3B8),
        questionBoxBg: const Color(0xFF1E294B),
        questionBoxBorder: const Color(0xFF3B82F6),
        optionBg: const Color(0xFF334155),
        optionBorder: const Color(0xFF475569),
        dividerColor: const Color(0xFF334155),
      );
}
