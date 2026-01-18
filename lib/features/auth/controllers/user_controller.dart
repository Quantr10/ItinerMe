import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user.dart';
import '../../../core/repositories/user_repository.dart';

class UserController extends ChangeNotifier {
  UserModel? _user;
  final UserRepository _userRepo;

  UserController({required UserRepository userRepository})
    : _userRepo = userRepository;

  UserModel? get user => _user;

  Future<void> fetchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final userModel = await _userRepo.getUserById(firebaseUser.uid);
    if (userModel == null) return;

    _user = userModel;
    notifyListeners();
  }

  Future<void> updateUser(UserModel updated) async {
    await _userRepo.createOrUpdateUser(updated);
    _user = updated;
    notifyListeners();
  }

  Future<void> updateUserAvatar(String newAvatarUrl) async {
    if (_user == null) return;

    await _userRepo.updateAvatar(_user!.id, newAvatarUrl);

    _user = _user!.copyWith(avatarUrl: newAvatarUrl);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
