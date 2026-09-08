import 'package:flutter/material.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/buttons/primary_button.dart';
import 'package:smart_task_manager/src/design_system/widgets/cards/app_card.dart';
import 'package:smart_task_manager/src/design_system/widgets/inputs/app_text_field.dart';
import 'package:smart_task_manager/src/features/auth/presentation/widgets/auth_tab_header.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.formKey,
    required this.isSignUp,
    required this.isLoading,
    required this.obscurePassword,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onTabChanged,
    required this.onToggleObscurePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final bool isSignUp;
  final bool isLoading;
  final bool obscurePassword;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueChanged<bool> onTabChanged;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Auth Mode Header
            AuthTabHeader(
              isSignUp: isSignUp,
              onTabChanged: onTabChanged,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name input (for Sign Up)
            if (isSignUp) ...[
              AppTextField(
                label: 'Full Name',
                controller: nameController,
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Email input
            AppTextField(
              label: 'Email Address',
              controller: emailController,
              hintText: 'name@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Password input
            AppTextField(
              label: 'Password',
              controller: passwordController,
              hintText: '••••••••',
              obscureText: obscurePassword,
              prefixIcon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colors.subText,
                  size: 20,
                ),
                onPressed: onToggleObscurePassword,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            PrimaryButton(
              text: isSignUp ? 'Create Account' : 'Sign In',
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
