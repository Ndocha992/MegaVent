import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/dashboard_stats.dart'; // Import the correct model

class AdminStatsOverview extends StatelessWidget {
  final DashboardStats stats; // Using the correct DashboardStats model

  const AdminStatsOverview({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Events',
                stats.totalEvents.toString(),
                Icons.event,
                AppConstants.primaryColor,
                _calculateGrowthPercentage('events'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Attendees',
                stats.totalAttendees.toString(),
                Icons.people,
                AppConstants.secondaryColor,
                _calculateGrowthPercentage('attendees'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Staff',
                stats.totalStaff.toString(),
                Icons.badge,
                AppConstants.accentColor,
                _calculateGrowthPercentage('staff'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active',
                stats.activeEvents.toString(),
                Icons.trending_up,
                AppConstants.warningColor,
                _calculateGrowthPercentage('active'),
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
    String growthPercentage,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  growthPercentage,
                  style: AppConstants.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppConstants.headlineLarge.copyWith(color: color)),
          Text(title, style: AppConstants.bodySmall),
        ],
      ),
    );
  }

  // Calculate growth percentage based on available data
  String _calculateGrowthPercentage(String type) {
    // Since we don't have historical data, we'll calculate based on current stats
    switch (type) {
      case 'events':
        // Calculate based on completion rate
        if (stats.totalEvents > 0) {
          double completionRate =
              (stats.completedEvents / stats.totalEvents) * 100;
          return '+${completionRate.toStringAsFixed(0)}%';
        }
        return '+0%';
      case 'attendees':
        // Calculate based on event capacity utilization
        if (stats.totalEvents > 0) {
          // Assuming average event capacity and current attendees
          double utilizationRate =
              (stats.totalAttendees / (stats.totalEvents * 100)) * 100;
          return '+${utilizationRate.clamp(0, 99).toStringAsFixed(0)}%';
        }
        return '+0%';
      case 'staff':
        // Calculate based on staff per event ratio
        if (stats.totalEvents > 0) {
          double staffPerEvent = stats.totalStaff / stats.totalEvents;
          return '+${(staffPerEvent * 10).clamp(0, 50).toStringAsFixed(0)}%';
        }
        return '+0%';
      case 'active':
        // Calculate based on active vs total events
        if (stats.totalEvents > 0) {
          double activeRate = (stats.activeEvents / stats.totalEvents) * 100;
          return '+${activeRate.toStringAsFixed(0)}%';
        }
        return '+0%';
      default:
        return '+0%';
    }
  }
}
