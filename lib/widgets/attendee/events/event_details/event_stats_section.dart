import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class EventStatsSection extends StatelessWidget {
  final Event event;
  
  const EventStatsSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Registered',
              value: event.registeredCount.toString(),
              total: event.capacity.toString(),
              color: AppConstants.primaryColor,
              progress: event.registeredCount / event.capacity,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Attended',
              value: event.attendedCount.toString(),
              total: event.registeredCount.toString(),
              color: AppConstants.successColor,
              progress: event.registeredCount > 0 ? event.attendedCount / event.registeredCount : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String total,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppConstants.bodyMediumSecondary,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/$total',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppConstants.displaySmall.copyWith(
              color: color,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 12),
          
          // Progress Bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% ${title.toLowerCase()}',
            style: AppConstants.bodySmallSecondary,
          ),
        ],
      ),
    );
  }
}