import 'package:flutter/material.dart';

class EmptyDashboardState extends StatelessWidget {
  final bool isSearching;

  const EmptyDashboardState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isSearching ? Icons.search_off : Icons.travel_explore, size: 60),
        Text(isSearching ? 'No results found' : 'No trips available'),
      ],
    );
  }
}
