import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/location_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/event_details/location_actions.dart';
import 'package:megavent/widgets/organizer/events/event_details/location_details.dart';
import 'package:megavent/widgets/organizer/events/event_details/location_map.dart';

class EventLocationSection extends StatefulWidget {
  final Event event;

  const EventLocationSection({super.key, required this.event});

  @override
  State<EventLocationSection> createState() => _EventLocationSectionState();
}

class _EventLocationSectionState extends State<EventLocationSection> {
  late final LocationService _locationService;

  LatLng? _eventCoordinates;
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _initLocationData();
  }

  Future<void> _initLocationData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get event coordinates
      final eventCoords = await _locationService.getEventCoordinates(
        widget.event.location,
      );
      if (eventCoords != null) {
        setState(() {
          _eventCoordinates = eventCoords;
        });
      }

      // Get current position
      try {
        final currentCoords = await _locationService.getCurrentPosition();
        if (currentCoords != null) {
          setState(() {
            _currentPosition = currentCoords;
          });
        }
      } catch (e) {
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
      final bounds = LatLngBounds.fromPoints([
        _eventCoordinates!,
        _currentPosition!,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } else {
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
          _buildHeader(),
          const SizedBox(height: 16),
          LocationDetailsWidget(
            event: widget.event,
            currentPosition: _currentPosition,
            eventCoordinates: _eventCoordinates,
          ),
          const SizedBox(height: 16),
          LocationMapWidget(
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            eventCoordinates: _eventCoordinates,
            currentPosition: _currentPosition,
            mapController: _mapController,
            onRefresh: _initLocationData,
            onZoomToFit: _zoomToFitMarkers,
            event: widget.event,
          ),
          const SizedBox(height: 16),
          LocationActionsWidget(
            eventCoordinates: _eventCoordinates,
            event: widget.event,
            onShowSnackBar: _showSnackBar,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }
}
