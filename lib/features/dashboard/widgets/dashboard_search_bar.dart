import 'package:flutter/material.dart';
import 'package:itinerme/core/theme/app_theme.dart';

class DashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const DashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: AppTheme.inputDecoration(
        'Search trips and locations...',
        onClear: () {
          controller.clear();
          onChanged('');
        },
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
