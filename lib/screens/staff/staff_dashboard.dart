import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/models/staff_dashboard_stats.dart';
import 'package:megavent/screens/staff/events.dart';
import 'package:megavent/screens/staff/events_details.dart';
import 'package:megavent/screens/staff/qr_scanner.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/widgets/staff/dashboard/latest_attendees_card.dart';
import 'package:megavent/widgets/staff/dashboard/latest_events_card.dart';
import 'package:megavent/widgets/staff/dashboard/quick_actions_grid.dart';
import 'package:megavent/widgets/staff/dashboard/stats_overview.dart';
import 'package:megavent/widgets/staff/dashboard/welcome_card.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/app_bar.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DatabaseService _databaseService;
  late AuthService
  _authService;
  List<Event> _events = [];
  List<Attendee> _attendees = [];
  List<Registration> _registrations = [];
  Map<String, String> _eventIdToNameMap = {};
  StaffDashboardStats _dashboardStats = StaffDashboardStats(
    totalEvents: 0,
    totalConfirmed: 0,
    upcomingEvents: 0,
  );
  bool _isLoading = true;
  String? _error;
  String? _organizerId;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(
      context,
      listen: false,
    ); // Fixed: Assign to correct type
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
          await _loadDashboardData(); // Fixed: Added await for proper async handling
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load staff data: ${e.toString()}';
      });
    }
  }

  Future<void> _loadDashboardData() async {
    if (_organizerId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _databaseService.getEventsForOrganizer(_organizerId!),
        _databaseService.getStaffAttendees(
          FirebaseAuth.instance.currentUser!.uid,
        ),
        _databaseService.getStaffDashboardStats(
          FirebaseAuth.instance.currentUser!.uid,
        ),
        _databaseService.getEventIdToNameMap(),
        _databaseService.getAllRegistrations(),
      ]);

      setState(() {
        _events = results[0] as List<Event>;
        final allRegistrations = results[4] as List<Registration>;
        _attendees =
            (results[1] as List<Attendee>)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _attendees =
            _attendees.take(5).toList(); // Fixed: Separate the take operation

        final statsData = results[2] as Map<String, dynamic>;

        // Get all registrations for activity tracking
        _registrations = allRegistrations;

        // Calculate stats from events
        final totalEvents = _events.length;
        final now = DateTime.now();
        final upcomingEvents =
            _events.where((event) => event.startDate.isAfter(now)).length;

        _dashboardStats = StaffDashboardStats(
          totalEvents: totalEvents,
          totalConfirmed: statsData['totalConfirmed'] ?? 0,
          upcomingEvents: upcomingEvents,
        );

        _eventIdToNameMap = results[3] as Map<String, String>;
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
      case 'event':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const StaffEvents()));
        break;
      case 'scan_qr':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const StaffQRScanner()));
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
            const StaffWelcomeCard(),
            const SizedBox(height: 24),
            StaffStatsOverview(stats: _dashboardStats),
            const SizedBox(height: 24),
            StaffLatestEventsCard(limit: 5),
            const SizedBox(height: 24),
            StaffLatestAttendeesCard(
              attendees: _attendees,
              registrations: _registrations,
              eventNames: _eventIdToNameMap,
            ),
            const SizedBox(height: 24),
            StaffQuickActionsGrid(onNavigate: _handleQuickAction),
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
            .toList();
    upcomingEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
    final limitedEvents =
        upcomingEvents.take(3).toList(); // Fixed: Separate the operations

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
        limitedEvents.isEmpty
            ? _buildEmptyUpcomingEventsState()
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: limitedEvents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = limitedEvents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StaffEventsDetails(event: event),
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
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    final currentUserId =
        FirebaseAuth
            .instance
            .currentUser
            ?.uid; // Fixed: Get current user ID safely
    if (currentUserId == null) return [];

    return _registrations
        .where((reg) => reg.confirmedBy == currentUserId)
        .where(
          (reg) => reg.attendedAt != null,
        ) // Fixed: Ensure attendedAt is not null
        .map(
          (reg) => {
            'title': 'Confirmed attendance for ${reg.userId}',
            'time': _getTimeAgo(reg.attendedAt!),
            'icon': Icons.check_circle,
            'color': AppConstants.successColor,
            'isNew': true,
          },
        )
        .toList();
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
