import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/location_service.dart';
import 'package:megavent/utils/constants.dart';

class LocationActionsWidget extends StatelessWidget {
  final LatLng? eventCoordinates;
  final Event event;
  final Function(String) onShowSnackBar;

  const LocationActionsWidget({
    super.key,
    required this.eventCoordinates,
    required this.event,
    required this.onShowSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDirectionsButton(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShareButton(),
        ),
      ],
    );
  }

  Widget _buildDirectionsButton() {
    return OutlinedButton.icon(
      onPressed: eventCoordinates != null ? _handleGetDirections : null,
      icon: const Icon(Icons.directions),
      label: const Text('Get Directions'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        side: BorderSide(color: AppConstants.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: eventCoordinates != null ? _handleShareLocation : null,
      icon: const Icon(Icons.share),
      label: const Text('Share Location'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _handleGetDirections() async {
    if (eventCoordinates == null) {
      onShowSnackBar('Event location not available');
      return;
    }

    final locationService = LocationService();
    final success = await locationService.openDirections(eventCoordinates!);
    
    if (!success) {
      onShowSnackBar('Could not open maps application');
    }
  }

  void _handleShareLocation() {
    if (eventCoordinates == null) {
      onShowSnackBar('Event location not available');
      return;
    }

    final locationService = LocationService();
    locationService.shareLocation(event.location, eventCoordinates!);
  }
}