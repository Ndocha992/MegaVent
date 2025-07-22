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
  late AuthService _authService;
  List<Event> _events = [];
  List<Attendee> _attendees = [];
  List<Registration> _registrations = [];
  List<Registration> _staffConfirmedRegistrations = [];
  Map<String, String> _eventIdToNameMap = {};
  StaffDashboardStats _dashboardStats = StaffDashboardStats(
    totalEvents: 0,
    totalConfirmed: 0,
    upcomingEvents: 0,
  );
  bool _isLoading = true;
  String? _error;
  String? _organizerId;

  Map<String, Registration> _compositeIdToRegistrationMap = {};
  Map<String, Attendee> _compositeIdToAttendeeMap = {};

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadStaffOrganizerId();
  }

  Future<void> _loadStaffOrganizerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🔍 STAFF DEBUG: Loading organizer ID for staff: ${user.uid}');

        final staffDoc =
            await FirebaseFirestore.instance
                .collection('staff')
                .doc(user.uid)
                .get();

        if (staffDoc.exists) {
          final organizerId = staffDoc.data()?['organizerId'];
          print('✅ STAFF DEBUG: Found organizer ID: $organizerId');

          setState(() {
            _organizerId = organizerId;
          });
          await _loadDashboardData();
        } else {
          print('❌ STAFF DEBUG: Staff document does not exist');
          setState(() {
            _error = 'Staff record not found';
          });
        }
      } else {
        print('❌ STAFF DEBUG: No authenticated user found');
        setState(() {
          _error = 'User not authenticated';
        });
      }
    } catch (e) {
      print('❌ STAFF DEBUG: Error loading staff organizer ID: $e');
      setState(() {
        _error = 'Failed to load staff data: ${e.toString()}';
      });
    }
  }

  Future<void> _loadDashboardData() async {
    if (_organizerId == null) {
      print('❌ STAFF DEBUG: No organizer ID available');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final currentStaffId = FirebaseAuth.instance.currentUser!.uid;
      print(
        '🔍 STAFF DEBUG: Loading dashboard data for organizer: $_organizerId, staff: $currentStaffId',
      );

      // 1. Load organizer's events
      final events = await _databaseService.getEventsForOrganizer(
        _organizerId!,
      );
      print('📊 STAFF DEBUG: Loaded ${events.length} events');

      if (events.isEmpty) {
        setState(() {
          _events = events;
          _attendees = [];
          _registrations = [];
          _staffConfirmedRegistrations = [];
          _eventIdToNameMap = {};
          _dashboardStats = StaffDashboardStats(
            totalEvents: 0,
            totalConfirmed: 0,
            upcomingEvents: 0,
          );
          _isLoading = false;
        });
        return;
      }

      // 2. Get all registrations for organizer's events
      final eventIds = events.map((e) => e.id).toList();
      final allRegistrations = await _getAllRegistrationsForEvents(eventIds);
      print(
        '📊 STAFF DEBUG: Loaded ${allRegistrations.length} total registrations',
      );

      // 3. Filter registrations confirmed by current staff
      final staffConfirmedRegistrations =
          allRegistrations
              .where((reg) => reg.confirmedBy == currentStaffId && reg.attended)
              .toList();
      print(
        '📊 STAFF DEBUG: Found ${staffConfirmedRegistrations.length} registrations confirmed by staff',
      );

      // 4. Get all attendees for organizer's events (similar to organizer dashboard)
      final attendees = await _getAllAttendeesForOrganizer(_organizerId!);
      print('📊 STAFF DEBUG: Loaded ${attendees.length} attendees');

      // 5. Sort attendees by registration date and get latest 5
      final sortedAttendees =
          _sortAttendeesByRegistrationDate(
            attendees,
            allRegistrations,
          ).take(5).toList();

      print(
        '📊 STAFF DEBUG: Sorted and limited to ${sortedAttendees.length} latest attendees',
      );

      setState(() {
        _events = events;
        _attendees = sortedAttendees;
        _registrations = allRegistrations;
        _staffConfirmedRegistrations = staffConfirmedRegistrations;

        // Create event ID to name map
        _eventIdToNameMap = {};
        for (final event in _events) {
          _eventIdToNameMap[event.id] = event.name;
        }

        // Create composite ID to registration map
        _compositeIdToRegistrationMap = {};
        for (final registration in _registrations) {
          final compositeId = Registration.getCompositeId(
            registration.userId,
            registration.eventId,
          );
          _compositeIdToRegistrationMap[compositeId] = registration;
        }

        // Create composite ID to attendee map
        _compositeIdToAttendeeMap = {};
        for (final attendee in attendees) {
          _compositeIdToAttendeeMap[attendee.id] = attendee;
        }

        // Update stats
        final upcomingEventsCount =
            _events.where((e) => e.startDate.isAfter(DateTime.now())).length;

        _dashboardStats = StaffDashboardStats(
          totalEvents: _events.length,
          totalConfirmed: staffConfirmedRegistrations.length,
          upcomingEvents: upcomingEventsCount,
        );

        print(
          '📊 STAFF DEBUG: Final stats - Events: ${_events.length}, Confirmed by Staff: ${staffConfirmedRegistrations.length}, Upcoming: $upcomingEventsCount',
        );

        _isLoading = false;
      });
    } catch (e) {
      print('❌ STAFF DEBUG: Error loading dashboard data: $e');
      setState(() {
        _error = 'Failed to load dashboard data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // NEW: Custom method to get all registrations for specific events
  Future<List<Registration>> _getAllRegistrationsForEvents(
    List<String> eventIds,
  ) async {
    try {
      if (eventIds.isEmpty) return [];

      // Split into chunks of 10 for Firestore whereIn limit
      List<Registration> allRegistrations = [];
      final chunks = <List<String>>[];
      for (int i = 0; i < eventIds.length; i += 10) {
        chunks.add(eventIds.skip(i).take(10).toList());
      }

      for (final chunk in chunks) {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('registrations')
                .where('eventId', whereIn: chunk)
                .orderBy('registeredAt', descending: true)
                .get();

        final chunkRegistrations =
            snapshot.docs
                .map((doc) => Registration.fromFirestore(doc))
                .toList();

        allRegistrations.addAll(chunkRegistrations);
      }

      return allRegistrations;
    } catch (e) {
      throw Exception('Failed to get registrations for events: $e');
    }
  }

  // NEW: Custom method to get all attendees for specific organizer (similar to organizer dashboard)
  Future<List<Attendee>> _getAllAttendeesForOrganizer(
    String organizerId,
  ) async {
    try {
      // Get all events by this organizer
      final eventsSnapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('organizerId', isEqualTo: organizerId)
              .get();

      if (eventsSnapshot.docs.isEmpty) {
        return [];
      }

      final eventIds = eventsSnapshot.docs.map((doc) => doc.id).toList();

      // Get all registrations for these events
      final registrations = await _getAllRegistrationsForEvents(eventIds);

      List<Attendee> attendees = [];

      for (final registration in registrations) {
        try {
          // Get user details
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('attendees')
                  .doc(registration.userId)
                  .get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data() as Map<String, dynamic>;

          // Composite ID format
          final compositeId = Registration.getCompositeId(
            registration.userId,
            registration.eventId,
          );

          // Create Attendee object with unique ID combining userId and eventId
          final attendee = Attendee(
            id: compositeId,
            fullName: userData['fullName'] ?? userData['name'] ?? 'Unknown',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            profileImage: userData['profileImage'],
            isApproved: true,
            createdAt:
                (userData['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
            updatedAt:
                (userData['updatedAt'] as Timestamp?)?.toDate() ??
                DateTime.now(),
          );

          attendees.add(attendee);
        } catch (e) {
          print(
            '❌ STAFF DEBUG: Error processing attendee for registration ${registration.id}: $e',
          );
          continue;
        }
      }

      return attendees;
    } catch (e) {
      throw Exception('Failed to get attendees for organizer: $e');
    }
  }

  // Helper method to sort attendees by registration date (same as organizer dashboard)
  List<Attendee> _sortAttendeesByRegistrationDate(
    List<Attendee> attendees,
    List<Registration> registrations,
  ) {
    // Create a map of composite ID to registration date for quick lookup
    final registrationDateMap = <String, DateTime>{};
    for (final registration in registrations) {
      final compositeId = Registration.getCompositeId(
        registration.userId,
        registration.eventId,
      );
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
            const StaffLatestEventsCard(limit: 5),
            const SizedBox(height: 24),
            StaffLatestAttendeesCard(
              attendees: _attendees,
              registrations: _registrations,
              eventNames: _eventIdToNameMap,
              compositeIdToRegistrationMap: _compositeIdToRegistrationMap,
              currentStaffId: FirebaseAuth.instance.currentUser!.uid,
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
              _events.isEmpty && _attendees.isEmpty
                  ? _buildEmptyActivityState()
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getRecentActivities().length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final activities = _getRecentActivities();
                      if (activities.isEmpty) return _buildEmptyActivityState();
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
              'Activity will appear here as you manage events',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StaffEvents()),
                );
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
    final limitedEvents = upcomingEvents.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StaffEvents()),
                );
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
              'Upcoming events will appear here',
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

  // Updated recent activities method (similar to organizer dashboard logic)
  List<Map<String, dynamic>> _getRecentActivities() {
    if (_events.isEmpty && _attendees.isEmpty) {
      print('📊 STAFF DEBUG: No data available for recent activities');
      return [];
    }

    List<Map<String, dynamic>> activities = [];

    // Add recent event activities (organizer events this staff can see)
    for (final event in _events.take(2)) {
      activities.add({
        'title': 'Event "${event.name}" created by your Organizer',
        'time': _getTimeAgo(event.createdAt),
        'icon': Icons.event,
        'color': AppConstants.primaryColor,
        'isNew': _isRecent(event.createdAt),
        'dateTime': event.createdAt,
      });
    }

    // Add recent attendee registration activities
    for (final attendee in _attendees.take(3)) {
      // Find the registration for this attendee
      final registration = _registrations.firstWhere(
        (reg) =>
            Registration.getCompositeId(reg.userId, reg.eventId) == attendee.id,
        orElse:
            () => Registration(
              id: '',
              userId: attendee.id.split('_').first,
              eventId: attendee.id.split('_').last,
              registeredAt: attendee.createdAt,
              attended: false,
              qrCode: '',
              confirmedBy: '',
            ),
      );

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

    // Add staff confirmation activities
    for (final registration in _staffConfirmedRegistrations.take(2)) {
      final attendee =
          _compositeIdToAttendeeMap[Registration.getCompositeId(
            registration.userId,
            registration.eventId,
          )];
      final eventName =
          _eventIdToNameMap[registration.eventId] ?? 'Unknown Event';
      final attendeeName =
          attendee?.fullName ??
          'Attendee ${registration.userId.substring(0, 8)}';

      activities.add({
        'title': 'Confirmed $attendeeName for "$eventName"',
        'time':
            registration.attendedAt != null
                ? _getTimeAgo(registration.attendedAt!)
                : 'Recently',
        'icon': Icons.check_circle,
        'color': AppConstants.accentColor,
        'isNew':
            registration.attendedAt != null
                ? _isRecent(registration.attendedAt!)
                : true,
        'dateTime': registration.attendedAt ?? DateTime.now(),
      });
    }

    // Sort by most recent
    activities.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

    // Remove the dateTime field after sorting
    for (var activity in activities) {
      activity.remove('dateTime');
    }

    print('📊 STAFF DEBUG: Generated ${activities.length} recent activities');
    return activities.take(6).toList();
  }

  bool _isRecent(DateTime dateTime) {
    return DateTime.now().difference(dateTime).inDays < 7;
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
