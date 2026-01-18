// lib/features/account/controller/account_controller.dart

import 'package:flutter/material.dart';
import 'package:itinerme/features/account/state/account_state.dart';

import '../../../core/services/account_service.dart';

class AccountController extends ChangeNotifier {
  final AccountService accountService;

  AccountState _state = const AccountState();
  AccountState get state => _state;

  AccountController({required this.accountService});

  Future<void> pickAndUploadAvatar(String userId) async {
    _state = _state.copyWith(isUploading: true);
    notifyListeners();

    try {
      final url = await accountService.pickAndUploadAvatar(userId);

      // user cancel pick image -> url null
      if (url == null) {
        _state = _state.copyWith(isUploading: false);
        notifyListeners();
        return;
      }

      _state = _state.copyWith(isUploading: false, avatarUrl: url);
      notifyListeners();
    } catch (_) {
      _state = _state.copyWith(isUploading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() => accountService.logout();
}
