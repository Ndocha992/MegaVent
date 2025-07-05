import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/attendee_stats.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/attendee/my_events_details.dart';
import 'package:megavent/widgets/attendee/dashboard/latest_events_section.dart';
import 'package:megavent/widgets/attendee/dashboard/my_registered_events_section.dart';
import 'package:megavent/widgets/attendee/dashboard/quick_actions_section.dart';
import 'package:megavent/widgets/attendee/dashboard/recent_activity_section.dart';
import 'package:megavent/widgets/attendee/dashboard/stats_overview.dart';
import 'package:megavent/widgets/attendee/dashboard/upcoming_events_section.dart';
import 'package:megavent/widgets/attendee/dashboard/welcome_card.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/app_bar.dart';

class AttendeeDashboard extends StatefulWidget {
  const AttendeeDashboard({super.key});

  @override
  State<AttendeeDashboard> createState() => _AttendeeDashboardState();
}

class _AttendeeDashboardState extends State<AttendeeDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DatabaseService _databaseService;
  List<Event> _allLatestEvents = [];
  List<Registration> _myRegistrations = [];
  List<Event> _myRegisteredEvents = [];
  AttendeeStats _attendeeStats = AttendeeStats(
    registeredEvents: 0,
    attendedEvents: 0,
    notAttendedEvents: 0,
    upcomingEvents: 0,
  );
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user ID from auth
      final currentUser =
          Provider.of<DatabaseService>(context, listen: false).currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _currentUserId = currentUser.uid;

      // Load user registrations first
      final myRegistrations = await _databaseService.getUserRegistrations(
        _currentUserId!,
      );

      // Load all available events
      final allEvents = await _databaseService.getAllAvailableEvents();

      // Get events for which user is registered by directly querying database
      List<Event> myRegisteredEvents = [];
      if (myRegistrations.isNotEmpty) {
        // Extract unique event IDs from registrations
        final eventIds =
            myRegistrations.map((reg) => reg.eventId).toSet().toList();

        // Fetch events directly from database
        for (String eventId in eventIds) {
          try {
            final event = await _databaseService.getEventById(eventId);
            if (event != null) {
              myRegisteredEvents.add(event);
            } else {
              debugPrint('Event not found for ID: $eventId');
            }
          } catch (e) {
            debugPrint('Error fetching event $eventId: $e');
          }
        }
      }

      // Get latest events from all organizers (limit to 10)
      final latestEvents = List<Event>.from(allEvents)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Calculate upcoming events correctly
      final now = DateTime.now();

      final upcomingEventsList =
          myRegisteredEvents.where((event) {
            // Parse start time
            final startTimeParts = event.startTime.split(':');
            final startHour = int.parse(startTimeParts[0]);
            final startMinute = int.parse(startTimeParts[1].split(' ')[0]);
            final isStartPM = event.startTime.contains('PM') && startHour != 12;

            // Parse end time
            final endTimeParts = event.endTime.split(':');
            final endHour = int.parse(endTimeParts[0]);
            final endMinute = int.parse(endTimeParts[1].split(' ')[0]);
            final isEndPM = event.endTime.contains('PM') && endHour != 12;

            // Create DateTime for event start and end
            final eventStartDateTime = DateTime(
              event.startDate.year,
              event.startDate.month,
              event.startDate.day,
              isStartPM ? startHour + 12 : startHour,
              startMinute,
            );

            final eventEndDateTime = DateTime(
              event.endDate.year,
              event.endDate.month,
              event.endDate.day,
              isEndPM ? endHour + 12 : endHour,
              endMinute,
            );

            // An event is upcoming if:
            // 1. It hasn't started yet (start time is in the future)
            // 2. It hasn't ended yet (end time is in the future)
            final isUpcoming =
                eventStartDateTime.isAfter(now) &&
                eventEndDateTime.isAfter(now);

            return isUpcoming;
          }).toList();

      // Create attendee stats from the fetched data
      final attendeeStats = AttendeeStats(
        registeredEvents: myRegistrations.length,
        attendedEvents: myRegistrations.where((r) => r.hasAttended).length,
        notAttendedEvents: myRegistrations.where((r) => !r.hasAttended).length,
        upcomingEvents: upcomingEventsList.length,
      );

      setState(() {
        _allLatestEvents = latestEvents.take(4).toList();
        _myRegistrations = myRegistrations;
        _myRegisteredEvents = myRegisteredEvents;
        _attendeeStats = attendeeStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'view_all_events':
        Navigator.of(context).pushReplacementNamed('/attendee-all-events');
        break;
      case 'view_my_events':
        Navigator.of(context).pushReplacementNamed('/attendee-my-events');
        break;
      case 'view_attendee_records':
        _showAttendeeRecordsDialog();
        break;
    }
  }

  void _showAttendeeRecordsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('My Attendee Records'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child:
                  _myRegistrations.isEmpty
                      ? const Center(child: Text('No attendee records found'))
                      : ListView.builder(
                        itemCount: _myRegistrations.length,
                        itemBuilder: (context, index) {
                          final record = _myRegistrations[index];
                          // Find the event from registered events
                          final event = _myRegisteredEvents.firstWhere(
                            (e) => e.id == record.eventId,
                          );
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(event.name),
                            subtitle: Text(
                              'Attended: ${record.hasAttended ? "Yes" : "No"}',
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: AttendeeSidebar(currentRoute: '/attendee-dashboard'),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: const Center(
        child: SpinKitThreeBounce(color: AppConstants.primaryColor, size: 20.0),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
          const SizedBox(height: 16),
          Text(
            'Error Loading Dashboard',
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
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AttendeeWelcomeCard(),
            const SizedBox(height: 24),
            StatsOverview(attendeeStats: _attendeeStats),
            const SizedBox(height: 24),
            LatestEventsSection(
              allLatestEvents: _allLatestEvents,
              onViewAll:
                  () => Navigator.of(
                    context,
                  ).pushReplacementNamed('/attendee-all-events'),
            ),
            const SizedBox(height: 24),
            MyRegisteredEventsSection(
              myRegistrations: _myRegistrations,
              eventCache: Map.fromEntries(
                _myRegisteredEvents.map((e) => MapEntry(e.id, e)),
              ),
              onViewAll:
                  () => Navigator.of(
                    context,
                  ).pushReplacementNamed('/attendee-my-events'),
              onEventTap:
                  (event) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => AttendeeMyEventsDetails(event: event),
                    ),
                  ),
            ),
            const SizedBox(height: 24),
            RecentActivitySection(
              myRegistrations: _myRegistrations,
              eventCache: Map.fromEntries(
                _myRegisteredEvents.map((e) => MapEntry(e.id, e)),
              ),
            ),
            const SizedBox(height: 24),
            UpcomingEventsSection(
              myRegistrations: _myRegistrations,
              eventCache: Map.fromEntries(
                _myRegisteredEvents.map((e) => MapEntry(e.id, e)),
              ),
              onViewAll:
                  () => Navigator.of(
                    context,
                  ).pushReplacementNamed('/attendee-my-events'),
              onEventTap:
                  (event) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => AttendeeMyEventsDetails(event: event),
                    ),
                  ),
            ),
            const SizedBox(height: 24),
            QuickActionsSection(onQuickAction: _handleQuickAction),
          ],
        ),
      ),
    );
  }
}
