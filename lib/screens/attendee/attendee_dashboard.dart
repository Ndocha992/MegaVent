import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/widgets/organizer/dashboard/welcome_card.dart';

// Custom stats model for attendee dashboard
class AttendeeStats {
  final int registeredEvents;
  final int attendedEvents;
  final int notAttendedEvents;
  final int upcomingEvents;

  AttendeeStats({
    required this.registeredEvents,
    required this.attendedEvents,
    required this.notAttendedEvents,
    required this.upcomingEvents,
  });
}

class AttendeeDashboard extends StatefulWidget {
  const AttendeeDashboard({super.key});

  @override
  State<AttendeeDashboard> createState() => _AttendeeDashboardState();
}

class _AttendeeDashboardState extends State<AttendeeDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DatabaseService _databaseService;
  List<Event> _allLatestEvents = []; // Latest events from all organizers
  List<Event> _myRegisteredEvents = []; // Events I'm registered for
  List<Registration> _myRegistrations = []; // My registration records
  Map<String, Event> _eventCache = {}; // Cache for event details
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

      // Load all data concurrently
      final results = await Future.wait([
        _databaseService.getAllAvailableEvents(),
        _databaseService.getUserRegistrations(_currentUserId!),
        _databaseService.getAttendeeRecords(_currentUserId!),
      ]);

      final allEvents = results[0] as List<Event>;
      final myRegistrations = results[1] as List<Registration>;

      // Build event cache for quick lookup
      Map<String, Event> eventCache = {};
      for (Event event in allEvents) {
        eventCache[event.id] = event;
      }

      // Get events for which user is registered
      List<Event> myRegisteredEvents = [];
      for (Registration registration in myRegistrations) {
        if (eventCache.containsKey(registration.eventId)) {
          myRegisteredEvents.add(eventCache[registration.eventId]!);
        }
      }

      // Get latest events from all organizers (limit to 10)
      final latestEvents =
          allEvents..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Create attendee stats from the fetched data
      final attendeeStats = AttendeeStats(
        registeredEvents: myRegistrations.length,
        attendedEvents: myRegistrations.where((r) => r.hasAttended).length,
        notAttendedEvents: myRegistrations.where((r) => !r.hasAttended).length,
        upcomingEvents:
            myRegisteredEvents
                .where((event) => event.startDate.isAfter(DateTime.now()))
                .length,
      );

      setState(() {
        _allLatestEvents = latestEvents.take(10).toList();
        _myRegisteredEvents = myRegisteredEvents;
        _myRegistrations = myRegistrations;
        _eventCache = eventCache;
        _attendeeStats = attendeeStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Dashboard loading error: $e');
    }
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'view_all_events':
        Navigator.of(context).pushReplacementNamed('/attendee-events');
        break;
      case 'view_my_events':
        Navigator.of(context).pushReplacementNamed('/my-events');
        break;
      case 'view_attendee_records':
        // Using _myAttendeeRecords here
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
                          final event = _eventCache[record.eventId];
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(event?.name ?? 'Unknown Event'),
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
            const WelcomeCard(),
            const SizedBox(height: 24),
            _buildStatsOverview(),
            const SizedBox(height: 24),
            _buildLatestEvents(),
            const SizedBox(height: 24),
            _buildMyRegisteredEvents(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildUpcomingEvents(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Event Overview', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Registered',
                _attendeeStats.registeredEvents.toString(),
                Icons.event_available,
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Attended',
                _attendeeStats.attendedEvents.toString(),
                Icons.check_circle,
                AppConstants.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Not Attended',
                _attendeeStats.notAttendedEvents.toString(),
                Icons.cancel,
                AppConstants.errorColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Upcoming',
                _attendeeStats.upcomingEvents.toString(),
                Icons.schedule,
                AppConstants.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: AppConstants.headlineMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/attendee-events');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _allLatestEvents.isEmpty
            ? _buildEmptyEventsState('No events available')
            : SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _allLatestEvents.take(5).length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final event = _allLatestEvents[index];
                  return _buildEventCard(event);
                },
              ),
            ),
      ],
    );
  }

  Widget _buildMyRegisteredEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Registered Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/my-events');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _myRegistrations.isEmpty
            ? _buildEmptyEventsState(
              'You haven\'t registered for any events yet',
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _myRegistrations.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final registration = _myRegistrations[index];
                final event = _eventCache[registration.eventId];
                if (event == null) return const SizedBox.shrink();
                return _buildMyEventTile(event, registration);
              },
            ),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      width: 160,
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(colors: AppConstants.primaryGradient),
              ),
              child: const Center(
                child: Icon(Icons.event, color: Colors.white, size: 32),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: AppConstants.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.location,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventTile(Event event, Registration registration) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => EventsDetails(event: event)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppConstants.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppConstants.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.startDate.day.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getMonthName(event.startDate.month),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: AppConstants.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.startTime} - ${event.endTime}',
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppConstants.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    registration.hasAttended
                        ? AppConstants.successColor.withOpacity(0.1)
                        : AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                registration.hasAttended ? 'Attended' : 'Registered',
                style: AppConstants.bodySmall.copyWith(
                  color:
                      registration.hasAttended
                          ? AppConstants.successColor
                          : AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _myRegistrations.isEmpty
                  ? _buildEmptyActivityState()
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getRecentActivities().length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activities = _getRecentActivities();
                      final activity = activities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: activity['color'].withOpacity(0.1),
                          child: Icon(
                            activity['icon'],
                            color: activity['color'],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          activity['title'],
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          activity['time'],
                          style: AppConstants.bodySmall,
                        ),
                        trailing:
                            activity['isNew']
                                ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppConstants.successColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                                : null,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    final upcomingRegistrations =
        _myRegistrations.where((registration) {
            final event = _eventCache[registration.eventId];
            return event != null && event.startDate.isAfter(DateTime.now());
          }).toList()
          ..sort((a, b) {
            final eventA = _eventCache[a.eventId];
            final eventB = _eventCache[b.eventId];
            if (eventA == null || eventB == null) return 0;
            return eventA.startDate.compareTo(eventB.startDate);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Upcoming Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/my-events');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        upcomingRegistrations.isEmpty
            ? _buildEmptyUpcomingEventsState()
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingRegistrations.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final registration = upcomingRegistrations[index];
                final event = _eventCache[registration.eventId]!;
                return _buildMyEventTile(event, registration);
              },
            ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'View All Events',
                    Icons.event,
                    AppConstants.primaryColor,
                    () => _handleQuickAction('view_all_events'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    'My Events',
                    Icons.bookmark,
                    AppConstants.accentColor,
                    () => _handleQuickAction('view_my_events'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    'Attendee Records',
                    Icons.person_pin,
                    AppConstants.successColor,
                    () => _handleQuickAction('view_attendee_records'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppConstants.cardDecoration,
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppConstants.textSecondaryColor.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics,
                            color: AppConstants.textSecondaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Statistics',
                          style: AppConstants.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_myRegisteredEvents.length} registered',
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppConstants.cardDecoration,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppConstants.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event, size: 48, color: AppConstants.primaryColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: AppConstants.primaryColor),
            const SizedBox(height: 16),
            Text(
              'No Recent Activity',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your activity will appear here as you register for events',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUpcomingEventsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Upcoming Events',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register for events to see them here',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/attendee-all-events');
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    if (_myRegistrations.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> activities = [];

    // Add registration activities
    for (final registration in _myRegistrations.take(5)) {
      final event = _eventCache[registration.eventId];
      if (event == null) continue;

      activities.add({
        'title': 'Registered for "${event.name}"',
        'time': _getTimeAgo(registration.registeredAt),
        'icon': Icons.event_available,
        'color': AppConstants.primaryColor,
        'isNew': _isRecent(registration.registeredAt),
        'dateTime': registration.registeredAt,
      });

      // Add attendance activity if attended
      if (registration.hasAttended && registration.attendedAt != null) {
        activities.add({
          'title': 'Attended "${event.name}"',
          'time': _getTimeAgo(registration.attendedAt!),
          'icon': Icons.check_circle,
          'color': AppConstants.successColor,
          'isNew': _isRecent(registration.attendedAt!),
          'dateTime': registration.attendedAt!,
        });
      }
    }

    // Sort by most recent
    activities.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

    // Remove dateTime field after sorting
    for (var activity in activities) {
      activity.remove('dateTime');
    }

    return activities.take(6).toList();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  bool _isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 6;
  }

  String _getMonthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}
