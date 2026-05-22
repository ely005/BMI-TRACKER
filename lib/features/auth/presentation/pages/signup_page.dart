import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/core/validators/auth_validator.dart';
import 'package:bmi_tracker/core/widgets/custom_button.dart';
import 'package:bmi_tracker/core/widgets/custom_text_field.dart';
import 'package:bmi_tracker/core/widgets/gradient_background.dart';
import 'package:bmi_tracker/features/auth/domain/requests/signup_request.dart';
import 'package:bmi_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bmi_tracker/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:bmi_tracker/features/auth/presentation/widgets/auth_header.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignupPressed() async {
    final AuthController controller = context.read<AuthController>();
    controller.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final SignupRequest request = SignupRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    final bool success = await controller.signup(request);
    if (!mounted) {
      return;
    }
    if (success) {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Consumer<AuthController>(
              builder: (BuildContext context, AuthController controller, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle:
                          'Start tracking your BMI and health journey today.',
                      icon: Icons.person_add_alt_1,
                    ),
                    const SizedBox(height: 24),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            CustomTextField(
                              controller: _nameController,
                              label: 'Name',
                              hint: 'Your full name',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                              validator: AuthValidator.validateName,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: AuthValidator.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: _obscurePassword,
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: AuthValidator.validatePassword,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              obscureText: _obscureConfirmPassword,
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (String? value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Password confirmation is required';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password confirmation does not match';
                                }
                                return null;
                              },
                            ),
                            if (controller.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                controller.errorMessage!,
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            CustomButton(
                              label: 'Create Account',
                              icon: Icons.person_add_rounded,
                              isLoading: controller.isLoading,
                              onPressed: _onSignupPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => context.go(RouteNames.login),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
