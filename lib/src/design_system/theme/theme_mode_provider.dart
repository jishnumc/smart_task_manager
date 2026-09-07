import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

/// Manages the application's [ThemeMode].
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  /// Updates the theme mode.
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  /// Toggles between light and dark mode.
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
