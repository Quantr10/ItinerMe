import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AccountController {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  AccountController({required this.firestore, required this.storage});

  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    final ref = storage.ref().child('user_avatars/$userId.jpg');
    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();

    await firestore.collection('users').doc(userId).update({
      'avatarUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return url;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
