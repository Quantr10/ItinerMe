import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itinerme/core/services/auth_service.dart';
import 'package:itinerme/core/repositories/user_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

import '../controllers/user_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_email_field.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_password_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final state = controller.state;
    final userController = context.read<UserController>();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    if (state.isLoading) {
      return Positioned.fill(child: AppTheme.loadingScreen(overlay: true));
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.largeHorizontalPadding,
          child: Column(
            children: [
              const AuthHeader(),

              AuthEmailField(controller: emailController),
              AppTheme.smallSpacing,

              AuthPasswordField(
                controller: passwordController,
                obscure: state.obscurePassword,
                onToggle: controller.togglePasswordVisibility,
              ),

              AppTheme.mediumSpacing,

              AppTheme.elevatedButton(
                label: 'LOGIN',
                onPressed: () async {
                  try {
                    await controller.loginEmail(
                      email: emailController.text,
                      password: passwordController.text,
                      userController: userController,
                    );
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    );
                  } catch (_) {
                    AppTheme.error('Login failed');
                  }
                },
                isPrimary: true,
              ),

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
                    AppTheme.error('Google login failed');
                  }
                },
              ),

              AppTheme.largeSpacing,

              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signup);
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
