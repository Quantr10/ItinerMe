import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinerme/core/services/auth_service.dart';
import 'package:itinerme/core/repositories/user_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_username_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => AuthController(
            authService: AuthService(
              auth: FirebaseAuth.instance,
              userRepository: UserRepository(),
            ),
          ),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final state = controller.state;
    final userController = context.read<UserController>();

    if (state.isLoading) {
      return Positioned.fill(child: AppTheme.loadingScreen(overlay: true));
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.largeHorizontalPadding,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthHeader(),

                // ===== Username =====
                AuthUsernameField(controller: _usernameController),

                AppTheme.smallSpacing,

                // ===== Email =====
                AuthEmailField(controller: _emailController),

                AppTheme.smallSpacing,

                // ===== Password =====
                AuthPasswordField(
                  controller: _passwordController,
                  obscure: state.obscurePassword,
                  onToggle: controller.togglePasswordVisibility,
                ),

                AppTheme.mediumSpacing,

                // ===== Sign Up Button =====
                AppTheme.elevatedButton(
                  label: 'SIGN UP',
                  isPrimary: true,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      await controller.signUpEmail(
                        email: _emailController.text,
                        password: _passwordController.text,
                        username: _usernameController.text,
                        userController: userController,
                      );

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    } catch (_) {
                      AppTheme.error('Sign up failed');
                    }
                  },
                ),

                // ===== Google Sign Up =====
                AuthGoogleButton(
                  onPressed: () async {
                    try {
                      await controller.loginWithGoogle(
                        userController: userController,
                      );

                      if (!context.mounted) return;
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    } catch (_) {
                      AppTheme.error('Google sign up failed');
                    }
                  },
                ),

                AppTheme.largeSpacing,

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        fontSize: AppTheme.defaultFontSize,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
