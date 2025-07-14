import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/admin_dashboard_stats.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/screens/admin/organizer.dart';
import 'package:megavent/screens/admin/organizer_details.dart';
import 'package:megavent/widgets/admin/dashboard/admin_quick_actions_grid.dart';
import 'package:megavent/widgets/admin/dashboard/admin_welcome_card.dart';
import 'package:megavent/widgets/admin/dashboard/admin_system_overview.dart';
import 'package:megavent/widgets/admin/dashboard/admin_organizers_section.dart';
import 'package:megavent/widgets/admin/dashboard/admin_events_section.dart';
import 'package:megavent/widgets/admin/dashboard/admin_staff_section.dart';
import 'package:megavent/widgets/admin/dashboard/admin_attendees_section.dart';
import 'package:megavent/widgets/admin/dashboard/admin_registrations_section.dart';
import 'package:megavent/widgets/admin/dashboard/admin_recent_activity.dart';
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
            AdminSystemOverview(
              organizers: _organizers,
              events: _events,
              staff: _staff,
              attendees: _attendees,
              registrations: _registrations,
            ),
            const SizedBox(height: 24),
            AdminOrganizersSection(
              organizers: _organizers,
              onViewAll:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrganizerScreen(),
                    ),
                  ),
              onOrganizerTap:
                  (Organizer organizer) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => OrganizerDetails(organizer: organizer),
                    ),
                  ),
            ),
            const SizedBox(height: 24),
            AdminEventsSection(events: _events),
            const SizedBox(height: 24),
            AdminStaffSection(staff: _staff),
            const SizedBox(height: 24),
            AdminAttendeesSection(attendees: _attendees),
            const SizedBox(height: 24),
            AdminRegistrationsSection(registrations: _registrations),
            const SizedBox(height: 24),
            AdminQuickActionsGrid(onNavigate: _handleQuickAction),
            const SizedBox(height: 24),
            AdminRecentActivity(
              events: _events,
              organizers: _organizers,
              registrations: _registrations,
            ),
          ],
        ),
      ),
    );
  }
}
