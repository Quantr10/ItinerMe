import 'dart:io';

class AccountState {
  final bool isUploading;
  final File? imageFile;

  const AccountState({this.isUploading = false, this.imageFile});

  AccountState copyWith({bool? isUploading, File? imageFile}) {
    return AccountState(
      isUploading: isUploading ?? this.isUploading,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
