import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_client.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

@Riverpod(keepAlive: true)
StorageClient storageClient(Ref ref) {
  return StorageClient(plugin: ref.watch(sharedPreferencesProvider));
}

/// {@template storage_client}
/// A client for storing data specifically using `shared_preferences`.
/// {@endtemplate}
class StorageClient {
  /// {@macro storage_client}
  const StorageClient({required SharedPreferences plugin}) : _plugin = plugin;

  final SharedPreferences _plugin;

  /// Saves a value of type [T] to local storage.
  ///
  /// Primitives (int, double, bool, String, `List<String>`) are stored directly
  /// Other types are encoded to a JSON string before storage.
  Future<bool> save<T>(String key, T value) {
    if (value is String) {
      return _plugin.setString(key, value);
    }
    if (value is int) {
      return _plugin.setInt(key, value);
    }
    if (value is double) {
      return _plugin.setDouble(key, value);
    }
    if (value is bool) {
      return _plugin.setBool(key, value);
    }
    if (value is List<String>) {
      return _plugin.setStringList(key, value);
    }
    return _plugin.setString(key, jsonEncode(value));
  }

  /// Reads a value of type [T] from local storage.
  ///
  /// Returns `null` if the key does not exist or if the value cannot be
  /// cast/decoded to [T].
  T? read<T>(String key) {
    if (T == int) return _plugin.getInt(key) as T?;
    if (T == double) return _plugin.getDouble(key) as T?;
    if (T == bool) return _plugin.getBool(key) as T?;
    if (T == String) return _plugin.getString(key) as T?;
    if (T == List<String>) return _plugin.getStringList(key) as T?;

    final value = _plugin.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as T;
    } on Object catch (_) {
      return null;
    }
  }

  /// Deletes a value from local storage.
  Future<bool> delete(String key) => _plugin.remove(key);

  /// Clears all values from local storage.
  Future<bool> clear() => _plugin.clear();
}
