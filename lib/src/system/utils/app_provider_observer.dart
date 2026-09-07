import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [ProviderObserver] that logs provider additions, updates, and disposals.
final class AppProviderObserver extends ProviderObserver {
  const AppProviderObserver();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    if (kDebugMode) {
      final name = context.provider.name ?? context.provider.runtimeType;
      print('''
{
  "provider": "$name",
  "newValue": "$value"
}''');
    }
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      final name = context.provider.name ?? context.provider.runtimeType;
      print('''
{
  "provider": "$name",
  "newValue": "$newValue"
}''');
    }
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kDebugMode) {
      final name = context.provider.name ?? context.provider.runtimeType;
      print('''
{
  "provider": "$name",
  "disposed": true
}''');
    }
  }
}
