import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/theme/theme_mode_provider.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/secondary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/design_system/widgets/inputs/app_text_field.dart';

class DashboardProfileSettingsCard extends ConsumerWidget {
  const DashboardProfileSettingsCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.email,
    required this.isEditing,
    required this.isSaving,
    required this.selectedThemeMode,
    required this.onThemeModeSelected,
    required this.onSaveProfile,
    required this.onSignOut,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final String email;
  final bool isEditing;
  final bool isSaving;
  final ThemeMode selectedThemeMode;
  final ValueChanged<ThemeMode> onThemeModeSelected;
  final VoidCallback onSaveProfile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final activeThemeMode = ref.watch(themeModeProvider);

    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Full Name',
              controller: nameController,
              enabled: isEditing,
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
              controller: TextEditingController(text: email),
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
                  context: context,
                  activeThemeMode: activeThemeMode,
                  label: 'Dark Theme',
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode_outlined,
                ),
                _buildThemeChip(
                  context: context,
                  activeThemeMode: activeThemeMode,
                  label: 'Light Theme',
                  mode: ThemeMode.light,
                  icon: Icons.light_mode_outlined,
                ),
                _buildThemeChip(
                  context: context,
                  activeThemeMode: activeThemeMode,
                  label: 'System Theme',
                  mode: ThemeMode.system,
                  icon: Icons.settings_brightness_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (isEditing) ...[
              PrimaryButton(
                text: 'Save Changes',
                isLoading: isSaving,
                onPressed: onSaveProfile,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            SecondaryButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChip({
    required BuildContext context,
    required ThemeMode activeThemeMode,
    required String label,
    required ThemeMode mode,
    required IconData icon,
  }) {
    final colors = context.appColors;
    final isSelected =
        (isEditing ? selectedThemeMode : activeThemeMode) == mode;

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
      onSelected: isEditing
          ? (selected) {
              if (selected) {
                onThemeModeSelected(mode);
              }
            }
          : null,
    );
  }
}
