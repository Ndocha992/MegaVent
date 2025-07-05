import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/dashboard_stats.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/organizer/create_events.dart';
import 'package:megavent/screens/organizer/create_staff.dart';
import 'package:megavent/screens/organizer/qr_scanner.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/widgets/organizer/dashboard/latest_attendees_card.dart';
import 'package:megavent/widgets/organizer/dashboard/latest_events_card.dart';
import 'package:megavent/widgets/organizer/dashboard/latest_staff_card.dart';
import 'package:megavent/widgets/organizer/dashboard/quick_actions_grid.dart';
import 'package:megavent/widgets/organizer/dashboard/stats_overview.dart';
import 'package:megavent/widgets/organizer/dashboard/welcome_card.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DatabaseService _databaseService;
  List<Event> _events = [];
  List<Attendee> _attendees = [];
  List<Registration> _registrations = [];
  Map<String, String> _eventIdToNameMap = {};
  List<Staff> _staff = [];
  DashboardStats _dashboardStats = DashboardStats(
    totalEvents: 0,
    totalAttendees: 0,
    totalStaff: 0,
    activeEvents: 0,
    upcomingEvents: 0,
    completedEvents: 0,
  );
  bool _isLoading = true;
  String? _error;

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

      // Load all required data in parallel
      final results = await Future.wait([
        _databaseService.getEvents(),
        _databaseService
            .getAllAttendees(), // Get all attendees instead of just latest
        _databaseService.getAllStaff(),
        _databaseService.getOrganizerDashboardStats(),
        _databaseService.getAllRegistrations(),
        _databaseService.getEventIdToNameMap(), // Get event ID to name mapping
      ]);

      setState(() {
        _events = results[0] as List<Event>;

        // Get all attendees and then sort by registration date to get latest
        final allAttendees = results[1] as List<Attendee>;
        final allRegistrations = results[4] as List<Registration>;

        // Sort attendees by registration date (most recent first) and take top 5
        _attendees =
            _sortAttendeesByRegistrationDate(
              allAttendees,
              allRegistrations,
            ).take(5).toList();

        // Get only the latest 5 staff members, sorted by hire date
        final allStaff = results[2] as List<Staff>;
        _staff =
            allStaff
              ..sort((a, b) => b.hiredAt.compareTo(a.hiredAt))
              ..take(5).toList();

        // Convert Map data to DashboardStats object
        final statsData = results[3] as Map<String, dynamic>;
        _dashboardStats = DashboardStats(
          totalEvents: statsData['totalEvents'] ?? 0,
          totalAttendees: statsData['totalAttendees'] ?? 0,
          totalStaff: statsData['totalStaff'] ?? 0,
          activeEvents: statsData['activeEvents'] ?? 0,
          upcomingEvents: statsData['upcomingEvents'] ?? 0,
          completedEvents: statsData['completedEvents'] ?? 0,
        );

        // Get all registrations for activity tracking
        _registrations = allRegistrations;

        // Get event ID to name mapping
        _eventIdToNameMap = results[5] as Map<String, String>;

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

  // Helper method to sort attendees by registration date
  List<Attendee> _sortAttendeesByRegistrationDate(
    List<Attendee> attendees,
    List<Registration> registrations,
  ) {
    // Create a map of composite ID to registration date for quick lookup
    final registrationDateMap = <String, DateTime>{};

    for (final registration in registrations) {
      final compositeId = '${registration.userId}_${registration.eventId}';
      registrationDateMap[compositeId] = registration.registeredAt;
    }

    // Sort attendees by registration date (most recent first)
    attendees.sort((a, b) {
      final dateA = registrationDateMap[a.id] ?? a.createdAt;
      final dateB = registrationDateMap[b.id] ?? b.createdAt;
      return dateB.compareTo(dateA);
    });

    return attendees;
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'create_event':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CreateEvents()));
        break;
      case 'add_staff':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CreateStaff()));
        break;
      case 'scan_qr':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const QRScanner()));
        break;
    }
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
      drawer: StaffSidebar(currentRoute: '/staff-dashboard'),
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
            StatsOverview(stats: _dashboardStats),
            const SizedBox(height: 24),
            LatestEventsCard(limit: 5),
            const SizedBox(height: 24),
            LatestAttendeesCard(
              attendees: _attendees,
              registrations: _registrations,
              eventNames: _eventIdToNameMap,
            ),
            const SizedBox(height: 24),
            LatestStaffCard(staff: _staff),
            const SizedBox(height: 24),
            QuickActionsGrid(onNavigate: _handleQuickAction),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildUpcomingEvents(),
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
              _events.isEmpty
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

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
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
              'Activity will appear here as you manage your events',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/organizer-events');
              },
              icon: const Icon(Icons.event),
              label: const Text('View Events'),
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

  Widget _buildUpcomingEvents() {
    final upcomingEvents =
        _events
            .where((event) => event.startDate.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate))
          ..take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/organizer-events');
              },
              child: const Text('View All Events'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        upcomingEvents.isEmpty
            ? _buildEmptyUpcomingEventsState()
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = upcomingEvents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventsDetails(event: event),
                      ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${event.registeredCount}/${event.capacity}',
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.secondaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
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
              'Create your first event to get started',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateEvents()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
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
    if (_events.isEmpty && _attendees.isEmpty && _staff.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> activities = [];

    // Add recent event-related activities
    for (final event in _events.take(2)) {
      activities.add({
        'title': 'Event "${event.name}" created',
        'time': _getTimeAgo(event.createdAt),
        'icon': Icons.event,
        'color': AppConstants.primaryColor,
        'isNew': _isRecent(event.createdAt),
        'dateTime': event.createdAt,
      });
    }

    // Add recent attendee activities - use registeredAt from Registration model
    for (final attendee in _attendees.take(2)) {
      // Find the registration for this attendee using composite ID
      final registration = _registrations.firstWhere(
        (reg) => '${reg.userId}_${reg.eventId}' == attendee.id,
        orElse:
            () => Registration(
              id: '',
              userId: attendee.id.split('_').first,
              eventId: attendee.id.split('_').last,
              registeredAt: attendee.createdAt,
              hasAttended: false,
              qrCode: '',
            ),
      );

      // Get event name for the activity
      final eventName =
          _eventIdToNameMap[registration.eventId] ?? 'Unknown Event';

      activities.add({
        'title': '${attendee.fullName} registered for "$eventName"',
        'time': _getTimeAgo(registration.registeredAt),
        'icon': Icons.person_add,
        'color': AppConstants.successColor,
        'isNew': _isRecent(registration.registeredAt),
        'dateTime': registration.registeredAt,
      });
    }

    // Add recent staff activities
    for (final staff in _staff.take(2)) {
      activities.add({
        'title': 'Staff member ${staff.name} joined',
        'time': _getTimeAgo(staff.hiredAt),
        'icon': Icons.badge,
        'color': AppConstants.accentColor,
        'isNew': _isRecent(staff.hiredAt),
        'dateTime': staff.hiredAt,
      });
    }

    // Sort by most recent
    activities.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

    // Remove the dateTime field after sorting
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
