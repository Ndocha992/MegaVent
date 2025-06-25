import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/events/location_dialogs.dart';

class LocationMapWidget extends StatelessWidget {
  final bool isLoading;
  final String errorMessage;
  final LatLng? eventCoordinates;
  final LatLng? currentPosition;
  final MapController mapController;
  final VoidCallback onRefresh;
  final VoidCallback onZoomToFit;
  final Event event;

  const LocationMapWidget({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.eventCoordinates,
    required this.currentPosition,
    required this.mapController,
    required this.onRefresh,
    required this.onZoomToFit,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMapContent(context),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context) {
    if (isLoading) {
      return _buildMapPlaceholder(loading: true);
    }

    if (errorMessage.isNotEmpty || eventCoordinates == null) {
      return _buildMapPlaceholder(error: errorMessage);
    }

    return Stack(
      children: [
        _buildFlutterMap(),
        _buildMapControls(),
      ],
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: eventCoordinates!,
        initialZoom: 13.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        _buildTileLayer(),
        _buildMarkerLayer(),
      ],
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.megavent.app',
      maxZoom: 18,
      subdomains: const ['a', 'b', 'c'],
      additionalOptions: const {
        'attribution': '© OpenStreetMap contributors',
      },
    );
  }

  Widget _buildMarkerLayer() {
    return MarkerLayer(
      markers: [
        // Event marker (red pin)
        _buildEventMarker(),
        // Current position marker (blue pin)
        if (currentPosition != null) _buildCurrentPositionMarker(),
      ],
    );
  }

  Marker _buildEventMarker() {
    return Marker(
      point: eventCoordinates!,
      width: 50,
      height: 50,
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () => LocationDialogs.showLocationInfo(
            context,
            'Event Location',
            event.location,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.event,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildCurrentPositionMarker() {
    return Marker(
      point: currentPosition!,
      width: 50,
      height: 50,
      child: GestureDetector(
        onTap: () => _showLocationInfo(
          'Your Location',
          'Current Position',
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        children: [
          FloatingActionButton.small(
            heroTag: "zoom_fit",
            onPressed: onZoomToFit,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.center_focus_strong,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: "refresh_location",
            onPressed: onRefresh,
            backgroundColor: Colors.white,
            child: Icon(Icons.refresh, color: AppConstants.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder({bool loading = false, String error = ''}) {
    return Container(
      color: AppConstants.primaryColor.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 48,
            color: AppConstants.primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            loading
                ? 'Loading map...'
                : error.isNotEmpty
                    ? 'Could not load map'
                    : 'Interactive Map',
            style: AppConstants.bodyMedium.copyWith(
              color: error.isNotEmpty ? Colors.red : AppConstants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (loading) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
              ),
            ),
          ],
          if (error.isNotEmpty && !loading) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  void _showLocationInfo(String title, String address) {
    // Note: This needs to be called from a widget context
    // You might want to pass a BuildContext or make this a callback
  }
}

// Extension to add the context-dependent method
extension LocationMapWidgetContext on LocationMapWidget {
  void showLocationInfo(BuildContext context, String title, String address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(address),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}