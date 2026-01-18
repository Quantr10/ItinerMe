import 'package:flutter/material.dart';
import 'package:itinerme/core/services/auth_service.dart';

import '../state/auth_state.dart';
import 'user_controller.dart';

class AuthController extends ChangeNotifier {
  final AuthService authService;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  AuthController({required this.authService});

  void togglePasswordVisibility() {
    _state = _state.copyWith(obscurePassword: !_state.obscurePassword);
    notifyListeners();
  }

  // ============ LOGIN EMAIL ============

  Future<void> loginEmail({
    required String email,
    required String password,
    required UserController userController,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await authService.loginWithEmail(email: email, password: password);

      await userController.fetchUser();
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // ============ GOOGLE LOGIN ============

  Future<void> loginWithGoogle({required UserController userController}) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await authService.loginWithGoogle();
      await userController.fetchUser();
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  // ============ SIGN UP ============

  Future<void> signUpEmail({
    required String email,
    required String password,
    required String username,
    required UserController userController,
  }) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await authService.signUpEmail(
        email: email,
        password: password,
        username: username,
      );

      await userController.fetchUser();
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }
}
