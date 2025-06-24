import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class EventLocationSection extends StatelessWidget {
  final Event event;

  const EventLocationSection({super.key, required this.event});

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

                // Additional location details
                _buildLocationDetail(
                  icon: Icons.access_time,
                  title: 'Timezone',
                  value: _getTimezone(),
                ),
                const SizedBox(height: 8),
                _buildLocationDetail(
                  icon: Icons.info_outline,
                  title: 'Venue Type',
                  value: _getVenueType(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Map Placeholder
          // Container(
          //   height: 200,
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     color: AppConstants.primaryColor.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: AppConstants.primaryColor.withOpacity(0.2),
          //     ),
          //   ),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.map,
          //         size: 48,
          //         color: AppConstants.primaryColor.withOpacity(0.6),
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         'Interactive Map',
          //         style: AppConstants.bodyMedium.copyWith(
          //           color: AppConstants.primaryColor,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //       const SizedBox(height: 4),
          //       Text(
          //         'Tap to view location on map',
          //         style: AppConstants.bodySmallSecondary,
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 16),

          // Action Buttons
          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton.icon(
          //         onPressed: _handleGetDirections,
          //         icon: const Icon(Icons.directions),
          //         label: const Text('Get Directions'),
          //         style: OutlinedButton.styleFrom(
          //           foregroundColor: AppConstants.primaryColor,
          //           side: BorderSide(color: AppConstants.primaryColor),
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           padding: const EdgeInsets.symmetric(vertical: 12),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: ElevatedButton.icon(
          //         onPressed: _handleShareLocation,
          //         icon: const Icon(Icons.share),
          //         label: const Text('Share Location'),
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: AppConstants.primaryColor,
          //           foregroundColor: Colors.white,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           padding: const EdgeInsets.symmetric(vertical: 12),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
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
    // Simple timezone detection based on location
    final location = event.location.toLowerCase();
    if (location.contains('new york') || location.contains('ny')) {
      return 'EST (UTC-5)';
    } else if (location.contains('los angeles') ||
        location.contains('california')) {
      return 'PST (UTC-8)';
    } else if (location.contains('london')) {
      return 'GMT (UTC+0)';
    } else if (location.contains('tokyo')) {
      return 'JST (UTC+9)';
    } else {
      return 'Local Time';
    }
  }

  String _getVenueType() {
    final location = event.location.toLowerCase();
    if (location.contains('center') || location.contains('hall')) {
      return 'Conference Center';
    } else if (location.contains('hotel')) {
      return 'Hotel Venue';
    } else if (location.contains('university') ||
        location.contains('college')) {
      return 'Educational Facility';
    } else if (location.contains('park') || location.contains('outdoor')) {
      return 'Outdoor Venue';
    } else {
      return 'Indoor Venue';
    }
  }

  void _handleGetDirections() {
    // Handle getting directions to the location
    // This would typically open a maps app or show directions
    print('Getting directions to: ${event.location}');
  }

  void _handleShareLocation() {
    // Handle sharing the location
    // This would typically open a share dialog
    print('Sharing location: ${event.location}');
  }
}
