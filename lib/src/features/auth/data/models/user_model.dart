import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';

/// Data model representing a User profile stored in Cloud Firestore.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.themeMode = ThemeMode.dark,
    super.createdAt,
  });

  /// Factory to convert a Firestore DocumentSnapshot to [UserModel].
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    final themeModeStr = data['themeMode'] as String? ?? 'dark';

    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      themeMode: _parseThemeMode(themeModeStr),
      createdAt: createdAt,
    );
  }

  /// Converts [UserModel] to Firestore document Map.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'themeMode': _themeModeToString(themeMode),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Convert [UserEntity] to [UserModel].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      themeMode: entity.themeMode,
      createdAt: entity.createdAt,
    );
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
