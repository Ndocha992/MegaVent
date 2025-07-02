import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeEventLocationSection extends StatelessWidget {
  final Event event;

  const AttendeeEventLocationSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Location', style: AppConstants.titleLarge),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.location,
                        style: AppConstants.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Timezone info
                _buildLocationDetail(
                  icon: Icons.access_time,
                  title: 'Timezone',
                  value: _getTimezone(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.textSecondaryColor, size: 16),
        const SizedBox(width: 8),
        Text('$title: ', style: AppConstants.bodySmallSecondary),
        Text(
          value,
          style: AppConstants.bodySmall.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _getTimezone() {
    // Enhanced timezone detection for more locations including Kenya
    final location = event.location.toLowerCase();

    // Kenya and East Africa
    if (location.contains('nakuru') ||
        location.contains('nairobi') ||
        location.contains('kenya') ||
        location.contains('kampala') ||
        location.contains('dar es salaam')) {
      return 'EAT (UTC+3)';
    }
    // US East Coast
    else if (location.contains('new york') ||
        location.contains('ny') ||
        location.contains('miami') ||
        location.contains('atlanta')) {
      return 'EST (UTC-5)';
    }
    // US West Coast
    else if (location.contains('los angeles') ||
        location.contains('california') ||
        location.contains('san francisco')) {
      return 'PST (UTC-8)';
    }
    // UK
    else if (location.contains('london') ||
        location.contains('manchester') ||
        location.contains('birmingham')) {
      return 'GMT (UTC+0)';
    }
    // Japan
    else if (location.contains('tokyo') ||
        location.contains('osaka') ||
        location.contains('kyoto')) {
      return 'JST (UTC+9)';
    }
    // South Africa
    else if (location.contains('cape town') ||
        location.contains('johannesburg') ||
        location.contains('durban')) {
      return 'SAST (UTC+2)';
    }
    // Nigeria
    else if (location.contains('lagos') ||
        location.contains('abuja') ||
        location.contains('nigeria')) {
      return 'WAT (UTC+1)';
    }
    // Default fallback
    else {
      return 'Local Time';
    }
  }
}
