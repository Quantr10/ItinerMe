import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;

  Future<void> fetchUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final userModel = await _userService.getUserById(firebaseUser.uid);

    // Nếu Firestore chưa kịp tạo → đợi 300ms rồi thử lại
    if (userModel == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      final retry = await _userService.getUserById(firebaseUser.uid);
      if (retry == null) return; // bỏ im lặng, không throw
      _user = retry;
    } else {
      _user = userModel;
    }

    notifyListeners();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _userService.createOrUpdateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> updateUserAvatar(String newAvatarUrl) async {
    if (_user != null) {
      _user = _user!.copyWith(avatarUrl: newAvatarUrl);
      notifyListeners();

      await _firestore.collection('users').doc(_user!.id).update({
        'avatarUrl': newAvatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
