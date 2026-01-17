import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/main_scaffold.dart';
import '../../../core/routes/app_routes.dart';

import '../../user/providers/user_provider.dart';
import '../controller/account_controller.dart';
import '../state/account_state.dart';
import '../widgets/account_info_card.dart';
import '../widgets/avatar_section.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final AccountController _controller;
  AccountState _state = const AccountState();

  @override
  void initState() {
    super.initState();
    _controller = AccountController(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  }

  Future<void> _pickAndUpload() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    setState(() => _state = _state.copyWith(isUploading: true));

    try {
      final url = await _controller.pickAndUploadAvatar(user.id);

      if (url == null) {
        setState(() => _state = _state.copyWith(isUploading: false));
        return;
      }

      context.read<UserProvider>().updateUserAvatar(url);
      AppTheme.success('Profile updated');
    } catch (_) {
      AppTheme.error('Upload failed');
    } finally {
      setState(() => _state = _state.copyWith(isUploading: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Stack(
      children: [
        MainScaffold(
          currentIndex: 3,
          body: Stack(
            children: [
              Padding(
                padding: AppTheme.defaultPadding,
                child: Column(
                  children: [
                    AvatarSection(
                      avatar:
                          user?.avatarUrl.isNotEmpty == true
                              ? NetworkImage(user!.avatarUrl)
                              : null,
                      isUploading: _state.isUploading,
                      onPickImage: _pickAndUpload,
                    ),
                    AppTheme.largeSpacing,
                    AccountInfoCard(
                      email: user?.email ?? '',
                      name: user?.name ?? '',
                    ),
                    AppTheme.largeSpacing,
                    AppTheme.elevatedButton(
                      label: 'LOG OUT',
                      isPrimary: false,
                      onPressed: () async {
                        await _controller.logout();
                        context.read<UserProvider>().clearUser();

                        if (!mounted) return;
                        AppTheme.success('Logged out successfully');

                        await Future.delayed(const Duration(milliseconds: 500));

                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.dashboard,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_state.isUploading)
          Positioned.fill(child: AppTheme.loadingScreen(overlay: true)),
      ],
    );
  }
}
