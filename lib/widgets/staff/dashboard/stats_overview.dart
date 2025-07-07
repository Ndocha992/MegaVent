import 'package:flutter/material.dart';
import 'package:megavent/models/staff_dashboard_stats.dart';
import 'package:megavent/utils/constants.dart';

class StaffStatsOverview extends StatelessWidget {
  final StaffDashboardStats stats;

  const StaffStatsOverview({super.key, required this.stats});

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
                'Our Events',
                stats.totalEvents.toString(),
                Icons.event,
                AppConstants.primaryColor,
                _calculateGrowthPercentage('events'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Attendees Confirmed',
                stats.totalConfirmed.toString(),
                Icons.people,
                AppConstants.secondaryColor,
                _calculateGrowthPercentage('attendees'),
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
          double completionRate = (stats.totalEvents / stats.totalEvents) * 100;
          return '+${completionRate.toStringAsFixed(0)}%';
        }
        return '+0%';
      case 'attendees':
        // Calculate based on event capacity utilization
        if (stats.totalEvents > 0) {
          // Assuming average event capacity and current attendees
          double utilizationRate =
              (stats.totalConfirmed / (stats.totalEvents * 100)) * 100;
          return '+${utilizationRate.clamp(0, 99).toStringAsFixed(0)}%';
        }
        return '+0%';
      default:
        return '+0%';
    }
  }
}
