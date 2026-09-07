import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_task_manager/src/system/utils/firebase_options.dart';
import 'package:smart_task_manager/src/outer_layer/clients/storage_client.dart';
import 'package:smart_task_manager/src/system/utils/app_provider_observer.dart';
import 'package:smart_task_manager/src/system/utils/scale_binding.dart';

Future<ProviderContainer> bootstrap() async {
  // Proportional scaling for different screen sizes
  // This also initializes the WidgetsBinding
  ScaleUiBinding.ensureInitialized(scaleResolver: _calculateScaleFactor);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize essential dependencies
  final sharedPref = await SharedPreferences.getInstance();

  // Create ProviderContainer with overrides
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPref)],
    observers: [const AppProviderObserver()],
  );
  // Read required providers so that they initialize correctly
  //..read(storageClientProvider);
  // ..read(settingsRepositoryProvider);

  return container;
}

/// Calculate the scale factor based on the screen size
double _calculateScaleFactor(Size size) {
  const double designWidth = 402;
  const double designHeight = 874;

  final widthScale = size.width / designWidth;
  final heightScale = size.height / designHeight;

  // Use min to ensure content fits.
  // Clamp(0.75, 1.05):
  // - 0.75: Supports iPhone SE (height constraint ~0.74) & small Androids.
  // - 1.05: Prevents excessive zooming on large screens
  // (Nothing Phone, S25 Ultra), keeping UI crisp.
  return min(widthScale, heightScale).clamp(0.75, 1.05);
}
