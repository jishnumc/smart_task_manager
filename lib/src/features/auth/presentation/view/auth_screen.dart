import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';
import 'package:smart_task_manager/src/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:smart_task_manager/src/features/auth/presentation/widgets/auth_header_branding.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);
    if (_isSignUp) {
      authNotifier.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );
    } else {
      authNotifier.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onError,
              ),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Branding Component
                AuthHeaderBranding(isSignUp: _isSignUp),
                const SizedBox(height: AppSpacing.xxl),

                // Form Card Component
                AuthFormCard(
                  formKey: _formKey,
                  isSignUp: _isSignUp,
                  isLoading: isLoading,
                  obscurePassword: _obscurePassword,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onTabChanged: (isSignUp) {
                    setState(() => _isSignUp = isSignUp);
                  },
                  onToggleObscurePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
