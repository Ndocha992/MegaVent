import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/location_service.dart';
import 'package:megavent/utils/constants.dart';

class LocationDetailsWidget extends StatelessWidget {
  final Event event;
  final LatLng? currentPosition;
  final LatLng? eventCoordinates;

  const LocationDetailsWidget({
    super.key,
    required this.event,
    required this.currentPosition,
    required this.eventCoordinates,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    
    return Container(
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
          _buildLocationHeader(),
          const SizedBox(height: 12),
          _buildLocationDetail(
            icon: Icons.access_time,
            title: 'Timezone',
            value: locationService.getTimezone(event.location),
          ),
          if (currentPosition != null && eventCoordinates != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildLocationDetail(
                icon: Icons.straighten,
                title: 'Distance',
                value: locationService.calculateDistance(
                  currentPosition!,
                  eventCoordinates!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
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
        Expanded(
          child: Text(
            value,
            style: AppConstants.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}