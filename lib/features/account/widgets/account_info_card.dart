import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AccountInfoCard extends StatelessWidget {
  final String email;
  final String name;

  const AccountInfoCard({super.key, required this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: AppTheme.defaultPadding,
        child: Column(
          children: [
            _row(Icons.email, email),
            const Divider(),
            _row(Icons.person, name),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
