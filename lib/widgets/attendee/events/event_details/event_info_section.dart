import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeEventInfoSection extends StatelessWidget {
  final Event event;

  const AttendeeEventInfoSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Information', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          // Date and Time
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: 'Date & Time',
            subtitle: _formatDateTime(),
          ),

          const SizedBox(height: 16),

          // Location
          _buildInfoRow(
            icon: Icons.location_on,
            title: 'Location',
            subtitle: event.location,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppConstants.bodyMediumSecondary),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppConstants.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    // Use the startTime and endTime strings from the Event model
    String timeRange = '${event.startTime} - ${event.endTime}';

    // Handle single day events
    if (event.startDate.day == event.endDate.day &&
        event.startDate.month == event.endDate.month &&
        event.startDate.year == event.endDate.year) {
      return '${months[event.startDate.month - 1]} ${event.startDate.day}, ${event.startDate.year}\n$timeRange';
    } else {
      // Handle multi-day events
      String startDateStr =
          '${months[event.startDate.month - 1]} ${event.startDate.day}, ${event.startDate.year}';
      String endDateStr =
          '${months[event.endDate.month - 1]} ${event.endDate.day}, ${event.endDate.year}';
      return '$startDateStr - $endDateStr\n$timeRange';
    }
  }
}
