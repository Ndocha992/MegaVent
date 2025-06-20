import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/screens/organizer/edit_events.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_header.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_info_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_stats_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_description_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_location_section.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions_section.dart';
import 'package:megavent/data/fake_data.dart';

class EventsDetails extends StatefulWidget {
  final Event? event;

  const EventsDetails({super.key, this.event});

  @override
  State<EventsDetails> createState() => _EventsDetailsState();
}

class _EventsDetailsState extends State<EventsDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-events';
  late Event currentEvent;

  @override
  void initState() {
    super.initState();
    // Use passed event or default to first event from fake data
    currentEvent = widget.event ?? FakeData.events.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentEvent.name),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Header with Image
            EventHeader(event: currentEvent),

            // Event Info Section
            EventInfoSection(event: currentEvent),

            // Event Stats
            EventStatsSection(event: currentEvent),

            // Event Description
            EventDescriptionSection(event: currentEvent),

            // Event Location
            EventLocationSection(event: currentEvent),

            // Action Buttons
            EventActionsSection(
              event: currentEvent,
              onEdit: _handleEditEvent,
              onDelete: _handleDeleteEvent,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleEditEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEvents(event: currentEvent)),
    );
  }

  void _handleDeleteEvent() {
    _showDeleteConfirmationDialog();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            'Are you sure you want to delete "${currentEvent.name}"? This action cannot be undone.',
            style: AppConstants.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppConstants.textSecondaryColor),
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
  }

  void _deleteEvent() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${currentEvent.name} has been deleted successfully'),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Navigate back to events list
    Navigator.of(context).pop();
  }
}
