import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmptyTripState extends StatelessWidget {
  final bool showingMyTrips;

  const EmptyTripState({super.key, required this.showingMyTrips});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            showingMyTrips ? Icons.travel_explore : Icons.bookmark_border,
            size: 60,
            color: AppTheme.secondaryColor,
          ),
          AppTheme.mediumSpacing,
          Text(
            showingMyTrips ? 'No trips created yet' : 'No trips saved yet',
            style: TextStyle(
              fontSize: AppTheme.largeFontSize,
              color: AppTheme.hintColor,
            ),
          ),
          AppTheme.smallSpacing,
          Text(
            showingMyTrips
                ? 'Start planning your first trip!'
                : 'Save trips to see them here',
            style: TextStyle(
              fontSize: AppTheme.defaultFontSize,
              color: AppTheme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
