import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/dashboard_stats.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/admin/organizer.dart';
import 'package:megavent/widgets/admin/dashboard/admin_quick_actions_grid.dart';
import 'package:megavent/widgets/admin/dashboard/admin_stats_overview.dart';
import 'package:megavent/widgets/admin/dashboard/admin_welcome_card.dart';
import 'package:megavent/widgets/admin/dashboard/latest_organizer_card.dart';
import 'package:megavent/widgets/admin/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/app_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late DatabaseService _databaseService;
  List<Event> _events = [];
  List<Attendee> _attendees = [];
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
      case 'organizers':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OrganizerScreen()),
        );
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
      drawer: AdminSidebar(currentRoute: '/admin-dashboard'),
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
            const AdminWelcomeCard(),
            const SizedBox(height: 24),
            AdminStatsOverview(stats: _dashboardStats),
            const SizedBox(height: 24),
            LatestOrganizerCard(staff: _staff),
            const SizedBox(height: 24),
            AdminQuickActionsGrid(onNavigate: _handleQuickAction),
            const SizedBox(height: 24),
            _buildRecentActivity(),
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

    // Add recent organizer-related activities
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
}
