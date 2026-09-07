import 'package:flutter/material.dart';

/// Domain entity representing an authenticated user profile.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.themeMode = ThemeMode.dark,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final ThemeMode themeMode;
  final DateTime? createdAt;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    ThemeMode? themeMode,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
