import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/theme/theme_mode_provider.dart';
import 'package:smart_task_manager/src/design_system/widgets/widgets.dart';
import 'package:smart_task_manager/src/features/auth/domain/entities/user_entity.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';

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
      _nameController.text = user.name;
      _selectedThemeMode = user.themeMode;
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authState = ref.watch(authProvider);

    if (authState is! Authenticated) {
      return const Scaffold(
        body: AppLoadingIndicator(message: 'Loading dashboard...'),
      );
    }

    final user = authState.user;
    _populateUserData(user);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
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
            onPressed: () {
              final newMode = context.isDarkMode
                  ? ThemeMode.light
                  : ThemeMode.dark;
              setState(() => _selectedThemeMode = newMode);
              ref.read(themeModeProvider.notifier).toggleTheme();
              ref.read(authProvider.notifier).updateProfile(
                    name: user.name,
                    themeMode: newMode,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Profile Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primary.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: context.textTheme.titleLarge?.copyWith(
                            color: colors.mainText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.subText,
                          ),
                        ),
                        if (user.createdAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Member since: ${_formatDate(user.createdAt!)}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: colors.subText.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile Edit Form Section Header
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
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    size: 18,
                  ),
                  label: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Profile Edit Card
            AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      enabled: _isEditing,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Email (Read Only)',
                      controller: TextEditingController(text: user.email),
                      enabled: false,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Theme Preference Selection
                    Text(
                      'Theme Preference',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: colors.mainText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        _buildThemeChip(
                          label: 'Dark Theme',
                          mode: ThemeMode.dark,
                          icon: Icons.dark_mode_outlined,
                        ),
                        _buildThemeChip(
                          label: 'Light Theme',
                          mode: ThemeMode.light,
                          icon: Icons.light_mode_outlined,
                        ),
                        _buildThemeChip(
                          label: 'System Theme',
                          mode: ThemeMode.system,
                          icon: Icons.settings_brightness_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    if (_isEditing)
                      PrimaryButton(
                        text: 'Save Changes',
                        isLoading: _isSaving,
                        onPressed: _saveProfile,
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

  Widget _buildThemeChip({
    required String label,
    required ThemeMode mode,
    required IconData icon,
  }) {
    final colors = context.appColors;
    final isSelected = _selectedThemeMode == mode;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colors.onPrimary : colors.subText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: colors.primary,
      backgroundColor: colors.optionBg,
      labelStyle: context.textTheme.labelMedium?.copyWith(
        color: isSelected ? colors.onPrimary : colors.subText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: _isEditing
          ? (selected) {
              if (selected) {
                setState(() => _selectedThemeMode = mode);
              }
            }
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
