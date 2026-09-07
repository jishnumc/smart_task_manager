import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/src/design_system/extensions/theme_extensions.dart';
import 'package:smart_task_manager/src/design_system/spacing/app_spacing.dart';
import 'package:smart_task_manager/src/design_system/widgets/widgets.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:smart_task_manager/src/features/auth/presentation/notifiers/auth_state.dart';

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
                // Header Branding
                Icon(
                  Icons.task_alt_rounded,
                  size: 64,
                  color: colors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Smart Task Manager',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: colors.mainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _isSignUp
                      ? 'Create an account to manage your tasks'
                      : 'Welcome back! Please sign in to continue',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.subText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Form Card
                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toggle Auth Mode Header
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_isSignUp
                                            ? colors.primary
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Sign In',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium?.copyWith(
                                      color: !_isSignUp
                                          ? colors.primary
                                          : colors.subText,
                                      fontWeight: !_isSignUp
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isSignUp
                                            ? colors.primary
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Register',
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.titleMedium?.copyWith(
                                      color: _isSignUp
                                          ? colors.primary
                                          : colors.subText,
                                      fontWeight: _isSignUp
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Name input (for Sign Up)
                        if (_isSignUp) ...[
                          AppTextField(
                            label: 'Full Name',
                            controller: _nameController,
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
                          controller: _emailController,
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
                          controller: _passwordController,
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: colors.subText,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
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
                          text: _isSignUp ? 'Create Account' : 'Sign In',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
