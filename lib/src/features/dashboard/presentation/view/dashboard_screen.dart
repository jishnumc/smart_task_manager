import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/theme/theme_mode_provider.dart';
import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/widgets/dashboard_profile_settings_card.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/widgets/dashboard_quick_action_card.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/widgets/dashboard_user_header_card.dart';
import 'package:smart_task_manager/src/features/dashboard/presentation/widgets/logout_confirmation_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  ThemeMode _selectedThemeMode = ThemeMode.dark;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _populateUserData(UserEntity user) {
    if (!_isEditing) {
      if (_nameController.text.isEmpty) {
        _nameController.text = user.name;
      }
      _selectedThemeMode = ref.read(themeModeProvider);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await ref.read(authProvider.notifier).updateProfile(
          name: _nameController.text,
          themeMode: _selectedThemeMode,
        );

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: context.appColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleLogout() {
    LogoutConfirmationDialog.show(
      context,
      onConfirm: () => ref.read(authProvider.notifier).signOut(),
    );
  }

  void _toggleThemeQuickAction(UserEntity user) {
    final currentMode = ref.read(themeModeProvider);
    final newMode =
        currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _selectedThemeMode = newMode);
    ref.read(themeModeProvider.notifier).setThemeMode(newMode);
    ref.read(authProvider.notifier).updateProfile(
          name: user.name,
          themeMode: newMode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authState = ref.watch(authProvider);

    final isLoading = authState is! Authenticated;
    final user = authState is Authenticated
        ? authState.user
        : UserEntity(
            id: 'dummy',
            email: 'loading.user@example.com',
            name: 'Task Manager User',
            createdAt: DateTime.now(),
          );

    if (!isLoading) {
      _populateUserData(user);
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: Skeletonizer(
        enabled: isLoading,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: const Text('Dashboard'),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Icon(
                    context.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: colors.primary,
                  ),
                  tooltip: 'Toggle Theme Quick Action',
                  onPressed: () => _toggleThemeQuickAction(user),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Sign Out',
                  onPressed: _handleLogout,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header Profile Card
                    DashboardUserHeaderCard(user: user),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick Actions Header
                    Text(
                      'Quick Actions',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.mainText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Two Action Cards: Create Task & View All Tasks
                    Row(
                      children: [
                        Expanded(
                          child: DashboardQuickActionCard(
                            title: 'Create Task',
                            subtitle: 'Add a new task',
                            icon: Icons.add_task_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/create-task'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DashboardQuickActionCard(
                            title: 'View All Tasks',
                            subtitle: 'Manage all tasks',
                            icon: Icons.task_alt_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/tasks'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Profile Settings Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Settings',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                              if (!_isEditing) {
                                _nameController.text = user.name;
                                _selectedThemeMode = user.themeMode;
                              }
                            });
                          },
                          icon: Icon(
                            _isEditing
                                ? Icons.close_rounded
                                : Icons.edit_rounded,
                            size: 18,
                          ),
                          label: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Profile Settings Card Component
                    DashboardProfileSettingsCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      email: user.email,
                      isEditing: _isEditing,
                      isSaving: _isSaving,
                      selectedThemeMode: _selectedThemeMode,
                      onThemeModeSelected: (mode) {
                        setState(() => _selectedThemeMode = mode);
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(mode);
                      },
                      onSaveProfile: _saveProfile,
                      onSignOut: _handleLogout,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
