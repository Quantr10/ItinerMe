import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SnackBarHelper {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void success(String message) {
    messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.accentColor,
          duration: AppTheme.messageDuration,
        ),
      );
  }

  static void error(String message) {
    messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          duration: AppTheme.messageDuration,
        ),
      );
  }
}
