import 'package:flutter/material.dart';
import 'package:megavent/models/attendee_stats.dart';
import 'package:megavent/utils/constants.dart';

class StatsOverview extends StatelessWidget {
  final AttendeeStats attendeeStats;

  const StatsOverview({
    super.key,
    required this.attendeeStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Event Overview', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Registered',
                attendeeStats.registeredEvents.toString(),
                Icons.event_available,
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Attended',
                attendeeStats.attendedEvents.toString(),
                Icons.check_circle,
                AppConstants.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Not Attended',
                attendeeStats.notAttendedEvents.toString(),
                Icons.cancel,
                AppConstants.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Upcoming',
                attendeeStats.upcomingEvents.toString(),
                Icons.schedule,
                AppConstants.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: AppConstants.headlineMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}