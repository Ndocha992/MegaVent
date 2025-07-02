import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions_section.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_description_section.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_header.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_info_section.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_location_section.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/services/database_service.dart';

class AttendeeEventsDetails extends StatefulWidget {
  final Event? event;
  final String?
  eventId; // Add eventId parameter for cases where we only have ID

  const AttendeeEventsDetails({super.key, this.event, this.eventId});

  @override
  State<AttendeeEventsDetails> createState() => _AttendeeEventsDetailsState();
}

class _AttendeeEventsDetailsState extends State<AttendeeEventsDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/attendee-all-events';

  late DatabaseService _databaseService;
  Event? currentEvent;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeEvent();
  }

  Future<void> _initializeEvent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.event != null) {
        // Use passed event
        setState(() {
          currentEvent = widget.event;
          _isLoading = false;
        });
      } else if (widget.eventId != null && widget.eventId!.isNotEmpty) {
        // Fetch event by ID
        final event = await _databaseService.getEventById(widget.eventId!);
        setState(() {
          currentEvent = event;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No event provided';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load event: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(
        screenTitle: currentEvent?.name ?? 'Event Details',
      ),
      drawer: AttendeeSidebar(currentRoute: currentRoute),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : currentEvent == null
              ? _buildNotFoundState()
              : _buildEventDetails(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: const Center(
              child: SpinKitThreeBounce(
                color: AppConstants.primaryColor,
                size: 20.0,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Loading event details...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error Loading Event',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _initializeEvent,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Event Not Found',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'The event you\'re looking for doesn\'t exist or has been deleted.',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return RefreshIndicator(
      onRefresh: _initializeEvent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendee Event Header with Image
            AttendeeEventHeader(event: currentEvent!),

            // Attendee Event Info Section
            AttendeeEventInfoSection(event: currentEvent!),

            // Attendee Event Description
            AttendeeEventDescriptionSection(event: currentEvent!),

            // Attendee Event Location
            AttendeeEventLocationSection(event: currentEvent!),

            // Action Buttons
            AttendeeEventActionsSection(event: currentEvent!),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
