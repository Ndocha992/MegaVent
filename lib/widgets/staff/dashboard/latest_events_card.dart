import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/screens/staff/events_details.dart';
import 'package:megavent/widgets/staff/events/event_card.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';

class StaffLatestEventsCard extends StatefulWidget {
  final int? limit; // Optional limit for number of events to show

  const StaffLatestEventsCard({super.key, this.limit = 5});

  @override
  State<StaffLatestEventsCard> createState() => _StaffLatestEventsCardState();
}

class _StaffLatestEventsCardState extends State<StaffLatestEventsCard> {
  late DatabaseService _databaseService;
  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;
  String? _organizerId;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadStaffOrganizerId();
  }

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
          await _loadLatestEvents();
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load staff data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLatestEvents() async {
    if (_organizerId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get events for the staff's organizer
      final events = await _databaseService.getEventsForOrganizer(
        _organizerId!,
      );

      // Filter events that haven't ended yet
      final now = DateTime.now();
      final activeEvents =
          events.where((event) {
            try {
              // Parse the end time (e.g., "10:00 PM")
              final endTimeParts =
                  event.endTime.replaceAll(' ', '').toLowerCase();
              final isPM = endTimeParts.contains('pm');
              final timeOnly = endTimeParts.replaceAll(RegExp(r'[ap]m'), '');

              final timeParts = timeOnly.split(':');
              if (timeParts.length != 2) return false;

              int hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);

              // Convert to 24-hour format
              if (isPM && hour != 12) {
                hour += 12;
              } else if (!isPM && hour == 12) {
                hour = 0;
              }

              // Combine end date with end time
              final eventEndDateTime = DateTime(
                event.endDate.year,
                event.endDate.month,
                event.endDate.day,
                hour,
                minute,
              );

              // Return true if event hasn't ended yet
              return now.isBefore(eventEndDateTime);
            } catch (e) {
              // If time parsing fails, exclude the event
              print('Error parsing time for event ${event.id}: $e');
              return false;
            }
          }).toList();

      // Sort events by creation date (most recent first)
      activeEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Limit events if specified
      final limitedEvents =
          widget.limit != null
              ? activeEvents.take(widget.limit!).toList()
              : activeEvents;

      setState(() {
        _events = limitedEvents;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/staff-events');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEventsSection(),
      ],
    );
  }

  Widget _buildEventsSection() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_events.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 220, // Adjusted height for compact cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: StaffEventCard(
              event: event,
              isCompact: true, // Use compact version
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StaffEventsDetails(event: event),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 220,
      decoration: AppConstants.cardDecoration,
      child: Container(
        color: AppConstants.primaryColor.withOpacity(0.1),
        child: const Center(
          child: SpinKitThreeBounce(
            color: AppConstants.primaryColor,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 220,
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppConstants.errorColor),
            const SizedBox(height: 12),
            Text(
              'Error Loading Events',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              child: ElevatedButton.icon(
                onPressed: _loadLatestEvents,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 40, color: AppConstants.primaryColor),
            const SizedBox(height: 12),
            Text(
              'No Events Yet',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Events will appear here once your Organizer creates events',
                textAlign: TextAlign.center,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
