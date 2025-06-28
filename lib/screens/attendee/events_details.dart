import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/screens/organizer/edit_events.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_header.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_info_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_stats_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_description_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_location_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions_section.dart';
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
  String currentRoute = '/organizer-events';

  late DatabaseService _databaseService;
  Event? currentEvent;
  bool _isLoading = true;
  String? _error;
  bool _isDeleting = false;

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
      drawer: OrganizerSidebar(currentRoute: currentRoute),
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
            EventHeader(event: currentEvent!),

            // Event Info Section
            EventInfoSection(event: currentEvent!),

            // Event Stats
            EventStatsSection(event: currentEvent!),

            // Event Description
            EventDescriptionSection(event: currentEvent!),

            // Event Location
            EventLocationSection(event: currentEvent!),

            // Action Buttons
            EventActionsSection(
              event: currentEvent!,
              onEdit: _handleEditEvent,
              onDelete: _handleDeleteEvent,
              isDeleting: _isDeleting,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleEditEvent() {
    if (currentEvent == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEvents(event: currentEvent!)),
    ).then((result) {
      // Refresh event details if the event was updated
      if (result != null && result is bool && result) {
        _initializeEvent();
      }
    });
  }

  void _handleDeleteEvent() {
    if (currentEvent == null) return;
    _showDeleteConfirmationDialog();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppConstants.errorColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Delete Event'),
                ],
              ),
              content: Text(
                'Are you sure you want to delete "${currentEvent!.name}"? This action cannot be undone.',
                style: AppConstants.bodyMedium,
              ),
              actions:
                  _isDeleting
                      ? [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Container(
                                  color: AppConstants.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  child: const Center(
                                    child: SpinKitThreeBounce(
                                      color: AppConstants.primaryColor,
                                      size: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Deleting...'),
                            ],
                          ),
                        ),
                      ]
                      : [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteEvent();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.errorColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteEvent() async {
    if (currentEvent == null) return;

    try {
      setState(() {
        _isDeleting = true;
      });

      // Delete event from database
      await _databaseService.deleteEvent(currentEvent!.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${currentEvent!.name} has been deleted successfully',
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back to events list
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
