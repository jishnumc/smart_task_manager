import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/theme/app_theme_dark.dart';
import 'package:smart_task_manager/src/design_system/theme/app_theme_light.dart';
import 'package:smart_task_manager/src/design_system/theme/theme_mode_provider.dart';
import 'package:smart_task_manager/src/design_system/typography/text_theme_native.dart';
import 'package:smart_task_manager/src/outer_layer/routing/app_router.dart';

/// The root application widget.
class App extends ConsumerWidget {
  /// Creates the root application widget.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Smart Task Manager',
      themeMode: themeMode,
      theme: const AppThemeLight(TextThemeNative()).themeData,
      darkTheme: const AppThemeDark(TextThemeNative()).themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
