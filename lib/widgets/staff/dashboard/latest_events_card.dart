import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/screens/organizer/create_events.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/event_card.dart';
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

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadLatestEvents();
  }

  Future<void> _loadLatestEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Listen to organizer events stream
      _databaseService.streamEventsByOrganizer().listen(
        (events) {
          if (mounted) {
            // Sort events by creation date (most recent first) and limit
            final sortedEvents = List<Event>.from(events);
            sortedEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final limitedEvents =
                widget.limit != null
                    ? sortedEvents.take(widget.limit!).toList()
                    : sortedEvents;

            setState(() {
              _events = limitedEvents;
              _isLoading = false;
              _error = null;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Failed to load events: ${error.toString()}';
              _isLoading = false;
            });
          }
        },
      );
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
                Navigator.of(context).pushReplacementNamed('/organizer-events');
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
            child: EventCard(
              event: event,
              isCompact: true, // Use compact version
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EventsDetails(event: event),
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
                'Create your first event to get started',
                textAlign: TextAlign.center,
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateEvents(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Create Event',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
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
}
