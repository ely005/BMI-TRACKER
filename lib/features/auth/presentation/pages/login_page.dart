import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/core/validators/auth_validator.dart';
import 'package:bmi_tracker/core/widgets/custom_button.dart';
import 'package:bmi_tracker/core/widgets/custom_text_field.dart';
import 'package:bmi_tracker/core/widgets/gradient_background.dart';
import 'package:bmi_tracker/features/auth/domain/requests/login_request.dart';
import 'package:bmi_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bmi_tracker/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:bmi_tracker/features/auth/presentation/widgets/auth_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final AuthController controller = context.read<AuthController>();
    controller.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final LoginRequest request = LoginRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final bool success = await controller.login(request);
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
                      title: 'Welcome Back',
                      subtitle:
                          'Track your BMI and monitor your health progress.',
                      icon: Icons.favorite_border,
                    ),
                    const SizedBox(height: 24),
                    AuthFormCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
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
                              label: 'Login',
                              icon: Icons.login_rounded,
                              isLoading: controller.isLoading,
                              onPressed: _onLoginPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => context.go(RouteNames.signup),
                      child: const Text("Don't have an account? Create Account"),
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
