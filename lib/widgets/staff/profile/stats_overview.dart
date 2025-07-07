import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/services/database_service.dart';

class StaffStatsOverview extends StatelessWidget {
  final Organizer organizer;
  final DatabaseService databaseService;

  const StaffStatsOverview({
    super.key,
    required this.organizer,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: databaseService.streamOrganizerStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {
          'totalEvents': 0,
          'totalAttendees': 0,
          'totalStaff': 0,
          'experienceLevel': 'Beginner'
        };

        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              // Top row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Events',
                      isLoading ? '...' : stats['totalEvents'].toString(),
                      Icons.event,
                      AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Attendees',
                      isLoading ? '...' : _formatNumber(stats['totalAttendees']),
                      Icons.people,
                      AppConstants.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Staff',
                      isLoading ? '...' : stats['totalStaff'].toString(),
                      Icons.group,
                      AppConstants.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Experience Level',
                      isLoading ? '...' : stats['experienceLevel'],
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 130, // Increased to 130 to accommodate all content
      padding: const EdgeInsets.all(14), // Slightly reduced padding
      decoration: AppConstants.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Reduced back to 6
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18), // Reduced back to 18
          ),
          const SizedBox(height: 8), // Reduced spacing
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: AppConstants.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // Slightly reduced
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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