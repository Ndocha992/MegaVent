import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/widgets/staff/events/event_details/event_actions_section.dart';
import 'package:megavent/widgets/staff/events/event_details/event_description_section.dart';
import 'package:megavent/widgets/staff/events/event_details/event_header.dart';
import 'package:megavent/widgets/staff/events/event_details/event_info_section.dart';
import 'package:megavent/widgets/staff/events/event_details/event_location_section.dart';
import 'package:megavent/widgets/staff/events/event_details/event_stats_section.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/services/database_service.dart';

class StaffEventsDetails extends StatefulWidget {
  final Event? event;
  final String? eventId;

  const StaffEventsDetails({super.key, this.event, this.eventId});

  @override
  State<StaffEventsDetails> createState() => _StaffEventsDetailsState();
}

class _StaffEventsDetailsState extends State<StaffEventsDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/staff-events';

  late DatabaseService _databaseService;
  Event? currentEvent;
  bool _isLoading = true;
  String? _error;
  String? _organizerId;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadStaffOrganizerId();
  }

  // Add method to load staff organizer ID
  Future<void> _loadStaffOrganizerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final staffDoc =
            await FirebaseFirestore.instance
                .collection('staff')
                .doc(user.uid)
                .get();

        if (staffDoc.exists) {
          setState(() {
            _organizerId = staffDoc.data()?['organizerId'];
          });
          await _initializeEvent();
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load staff data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeEvent() async {
    if (_organizerId == null) return;

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
        // Fetch event by ID, but ensure it belongs to the staff's organizer
        final events = await _databaseService.getEventsForOrganizer(
          _organizerId!,
        );
        final event = events.firstWhere(
          (e) => e.id == widget.eventId,
          orElse: () => throw Exception('Event not found'),
        );

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
      drawer: StaffSidebar(currentRoute: currentRoute),
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
            // Event Header with Image
            StaffEventHeader(event: currentEvent!),

            // Event Info Section
            StaffEventInfoSection(event: currentEvent!),

            // Event Stats
            StaffEventStatsSection(event: currentEvent!),

            // Event Description
            StaffEventDescriptionSection(event: currentEvent!),

            // Event Location
            StaffEventLocationSection(event: currentEvent!),

            // Action Buttons
            StaffEventActionsSection(event: currentEvent!),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
