import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class EventLocationSection extends StatefulWidget {
  final Event event;

  const EventLocationSection({super.key, required this.event});

  @override
  State<EventLocationSection> createState() => _EventLocationSectionState();
}

class _EventLocationSectionState extends State<EventLocationSection> {
  LatLng? _eventCoordinates;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initLocationData();
  }

  Future<void> _initLocationData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get event coordinates from address
      final eventLocation = await locationFromAddress(widget.event.location);
      if (eventLocation.isNotEmpty) {
        setState(() {
          _eventCoordinates = LatLng(
            eventLocation.first.latitude,
            eventLocation.first.longitude,
          );
        });
      }

      // Get current position
      try {
        Position position = await _determinePosition();
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        // Continue without current position if location access fails
        debugPrint('Could not get current position: $e');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load event location';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _handleGetDirections() async {
    if (_eventCoordinates == null) {
      _showSnackBar('Event location not available');
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${_eventCoordinates!.latitude},${_eventCoordinates!.longitude}'
      '&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open maps application');
      }
    } catch (e) {
      _showSnackBar('Error opening directions');
    }
  }

  void _handleShareLocation() {
    if (_eventCoordinates == null) {
      _showSnackBar('Event location not available');
      return;
    }

    final shareText = '''
📍 ${widget.event.location}

View on map: https://www.openstreetmap.org/?mlat=${_eventCoordinates!.latitude}&mlon=${_eventCoordinates!.longitude}&zoom=15

Get directions: https://www.google.com/maps/dir/?api=1&destination=${_eventCoordinates!.latitude},${_eventCoordinates!.longitude}
''';

    Share.share(shareText);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _zoomToFitMarkers() {
    if (_eventCoordinates == null) return;

    if (_currentPosition != null) {
      // Calculate bounds to fit both markers
      final bounds = LatLngBounds.fromPoints([
        _eventCoordinates!,
        _currentPosition!,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } else {
      // Just center on event location
      _mapController.move(_eventCoordinates!, 14.0);
    }
  }

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
                        widget.event.location,
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
                if (_currentPosition != null && _eventCoordinates != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildLocationDetail(
                      icon: Icons.straighten,
                      title: 'Distance',
                      value: _calculateDistance(),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Map
          Container(
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
              child: _buildMap(),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _eventCoordinates != null ? _handleGetDirections : null,
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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _eventCoordinates != null ? _handleShareLocation : null,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return _buildMapPlaceholder(loading: true);
    }

    if (_errorMessage.isNotEmpty || _eventCoordinates == null) {
      return _buildMapPlaceholder(error: _errorMessage);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _eventCoordinates!,
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.megavent.app',
              maxZoom: 18,
              subdomains: const ['a', 'b', 'c'],
              additionalOptions: const {
                'attribution': '© OpenStreetMap contributors',
              },
            ),
            MarkerLayer(
              markers: [
                // Event marker (red pin)
                Marker(
                  point: _eventCoordinates!,
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap:
                        () => _showLocationInfo(
                          'Event Location',
                          widget.event.location,
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
                // Current position marker (blue pin)
                if (_currentPosition != null)
                  Marker(
                    point: _currentPosition!,
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap:
                          () => _showLocationInfo(
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
                  ),
              ],
            ),
          ],
        ),
        // Map controls
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: "zoom_fit",
                onPressed: _zoomToFitMarkers,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.center_focus_strong,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "refresh_location",
                onPressed: _initLocationData,
                backgroundColor: Colors.white,
                child: Icon(Icons.refresh, color: AppConstants.primaryColor),
              ),
            ],
          ),
        ),
      ],
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
              onPressed: _initLocationData,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  void _showLocationInfo(String title, String address) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  String _calculateDistance() {
    if (_currentPosition == null || _eventCoordinates == null) return 'N/A';

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _eventCoordinates!.latitude,
      _eventCoordinates!.longitude,
    );

    if (distance < 1000) {
      return '${distance.round()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  String _getTimezone() {
    // Enhanced timezone detection for more locations including Kenya
    final location = widget.event.location.toLowerCase();

    // Kenya and East Africa
    if (location.contains('nakuru') ||
        location.contains('nyeri') ||
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
