import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/admin_dashboard_stats.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/admin/organizer.dart';
import 'package:megavent/widgets/admin/dashboard/admin_quick_actions_grid.dart';
import 'package:megavent/widgets/admin/dashboard/admin_welcome_card.dart';
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
  bool _isLoading = true;
  String? _error;

  // Admin dashboard data
  AdminDashboardStats? _adminDashboardStats;
  List<Organizer> _organizers = [];
  List<Event> _events = [];
  List<Staff> _staff = [];
  List<Attendee> _attendees = [];
  List<Registration> _registrations = [];

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
        _databaseService.getAdminDashboardStats(),
        _databaseService.getAdminAllOrganizers(),
        _databaseService.getAdminAllEvents(),
        _databaseService.getAdminAllStaff(),
        _databaseService.getAdminAllAttendees(),
        _databaseService.getAdminAllRegistrations(),
      ]);

      setState(() {
        _adminDashboardStats = results[0] as AdminDashboardStats;
        _organizers = results[1] as List<Organizer>;
        _events = results[2] as List<Event>;
        _staff = results[3] as List<Staff>;
        _attendees = results[4] as List<Attendee>;
        _registrations = results[5] as List<Registration>;

        // Sort data by most recent
        _organizers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _staff.sort((a, b) => b.hiredAt.compareTo(a.hiredAt));
        _attendees.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _registrations.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));

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
      case 'organizers':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OrganizerScreen()),
        );
        break;
      // Add more quick actions as needed
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
            _buildSystemOverview(),
            const SizedBox(height: 24),
            _buildOrganizersSection(),
            const SizedBox(height: 24),
            _buildEventsSection(),
            const SizedBox(height: 24),
            _buildStaffSection(),
            const SizedBox(height: 24),
            _buildAttendeesSection(),
            const SizedBox(height: 24),
            _buildRegistrationsSection(),
            const SizedBox(height: 24),
            AdminQuickActionsGrid(onNavigate: _handleQuickAction),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Overview', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Organizers',
              _organizers.length,
              Icons.business,
              AppConstants.primaryColor,
            ),
            _buildStatCard(
              'Events',
              _events.length,
              Icons.event,
              AppConstants.secondaryColor,
            ),
            _buildStatCard(
              'Staff',
              _staff.length,
              Icons.people,
              AppConstants.accentColor,
            ),
            _buildStatCard(
              'Attendees',
              _attendees.length,
              Icons.person,
              AppConstants.successColor,
            ),
            _buildStatCard(
              'Registrations',
              _registrations.length,
              Icons.how_to_reg,
              AppConstants.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      decoration: AppConstants.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: AppConstants.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Organizers (${_organizers.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrganizerScreen(),
                    ),
                  ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _organizers.isEmpty
                  ? _buildEmptyState('No organizers yet', Icons.business)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _organizers.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final organizer = _organizers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              organizer.profileImage != null
                                  ? NetworkImage(organizer.profileImage!)
                                  : null,
                          child:
                              organizer.profileImage == null
                                  ? Text(organizer.fullName[0].toUpperCase())
                                  : null,
                        ),
                        title: Text(
                          organizer.fullName,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          organizer.email,
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getTimeAgo(organizer.createdAt),
                              style: AppConstants.bodySmall.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Events (${_events.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to events screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _events.isEmpty
                  ? _buildEmptyState('No events yet', Icons.event)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _events.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.secondaryColor
                              .withOpacity(0.1),
                          child: Icon(
                            Icons.event,
                            color: AppConstants.secondaryColor,
                          ),
                        ),
                        title: Text(
                          event.name,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          '${event.location} • ${_formatDate(event.startDate)}',
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getTimeAgo(event.createdAt),
                              style: AppConstants.bodySmall.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildStaffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Staff (${_staff.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to staff screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _staff.isEmpty
                  ? _buildEmptyState('No staff yet', Icons.people)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _staff.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final staff = _staff[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.accentColor.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppConstants.accentColor,
                          ),
                        ),
                        title: Text(
                          staff.name,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          '${staff.email} • ${staff.role}',
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getTimeAgo(staff.hiredAt),
                              style: AppConstants.bodySmall.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildAttendeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Attendees (${_attendees.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to attendees screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _attendees.isEmpty
                  ? _buildEmptyState('No attendees yet', Icons.person)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendees.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final attendee = _attendees[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.successColor
                              .withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: AppConstants.successColor,
                          ),
                        ),
                        title: Text(
                          attendee.name,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          attendee.email,
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getTimeAgo(attendee.createdAt),
                              style: AppConstants.bodySmall.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRegistrationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Registrations (${_registrations.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to registrations screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              _registrations.isEmpty
                  ? _buildEmptyState('No registrations yet', Icons.how_to_reg)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _registrations.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final registration = _registrations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.warningColor
                              .withOpacity(0.1),
                          child: Icon(
                            Icons.how_to_reg,
                            color: AppConstants.warningColor,
                          ),
                        ),
                        title: Text(
                          'Registration #${registration.id}',
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          'Event: ${registration.eventId} • User: ${registration.userId}',
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    registration.hasAttended
                                        ? AppConstants.successColor
                                        : AppConstants.warningColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                registration.hasAttended
                                    ? 'Attended'
                                    : 'Pending',
                                style: AppConstants.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTimeAgo(registration.registeredAt),
                              style: AppConstants.bodySmall.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
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
              _getRecentActivities().isEmpty
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppConstants.textSecondaryColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
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
    List<Map<String, dynamic>> activities = [];

    // Add recent events
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

    // Add recent organizers
    for (final organizer in _organizers.take(2)) {
      activities.add({
        'title': 'Organizer "${organizer.fullName}" registered',
        'time': _getTimeAgo(organizer.createdAt),
        'icon': Icons.business,
        'color': AppConstants.secondaryColor,
        'isNew': _isRecent(organizer.createdAt),
        'dateTime': organizer.createdAt,
      });
    }

    // Add recent registrations
    for (final registration in _registrations.take(2)) {
      activities.add({
        'title': 'New registration received',
        'time': _getTimeAgo(registration.registeredAt),
        'icon': Icons.how_to_reg,
        'color': AppConstants.accentColor,
        'isNew': _isRecent(registration.registeredAt),
        'dateTime': registration.registeredAt,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 6;
  }
}
