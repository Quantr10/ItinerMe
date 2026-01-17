import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AccountController {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final ImagePicker _picker = ImagePicker();

  AccountController({required this.firestore, required this.storage});

  Future<String?> pickAndUploadAvatar(String userId) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;

    final imageFile = File(file.path);

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
