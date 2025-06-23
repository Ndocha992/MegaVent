import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/organizer.dart';

class StatsOverview extends StatelessWidget {
  final Organizer organizer;

  const StatsOverview({
    super.key,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // Slightly reduced height
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildStatCard(
            'Total Events',
            organizer.totalEvents.toString(),
            Icons.event,
            AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Attendees',
            _formatNumber(organizer.totalAttendees),
            Icons.people,
            AppConstants.secondaryColor,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Experience Level',
            organizer.experienceLevel,
            Icons.star,
            AppConstants.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 120, // Reduced width to prevent overflow
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: AppConstants.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20), // Smaller icon
          ),
          const SizedBox(height: 6), // Reduced spacing
          Text(
            value,
            style: AppConstants.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Smaller font
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2), // Reduced spacing
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
              fontSize: 11, // Smaller font
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}