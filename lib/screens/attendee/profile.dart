import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/attendee_stats.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/screens/attendee/edit_profile.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/attendee/profile/action_buttons.dart';
import 'package:megavent/widgets/attendee/profile/contact_info_section.dart';
import 'package:megavent/widgets/attendee/profile/personal_info_section.dart';
import 'package:megavent/widgets/attendee/profile/professional_info_section.dart';
import 'package:megavent/widgets/attendee/profile/profile_header_card.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendeeProfile extends StatefulWidget {
  const AttendeeProfile({super.key});

  @override
  State<AttendeeProfile> createState() => _AttendeeProfileState();
}

class _AttendeeProfileState extends State<AttendeeProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/attendee-profile';
  bool _isLoading = false;
  // Add a key to force StreamBuilder rebuild
  Key _streamBuilderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: AttendeeSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: StreamBuilder<Attendee?>(
          key: _streamBuilderKey, // Add key to force rebuild
          stream: databaseService.streamAttendeeData(),
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading overlay if not already showing
              if (!_isLoading) {
                _isLoading = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingOverlay.show(
                    context,
                    message: 'Loading your profile...',
                  );
                });
              }

              // Return empty container while loading overlay is shown
              return Container();
            } else {
              // Hide loading overlay when data is loaded
              if (_isLoading) {
                _isLoading = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingOverlay.hide();
                });
              }
            }

            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text('Error', style: AppConstants.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load profile data',
                          style: AppConstants.bodyLarge.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final attendee = snapshot.data;
            if (attendee == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: Text('No attendee data available'),
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: AppConstants.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your personal information and preferences',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profile Header Card
                  ProfileHeaderCard(attendee: attendee),
                  const SizedBox(height: 20),
                  // Stats Overview - Show attendee's personal stats
                  _buildAttendeeStatsOverview(attendee, databaseService),
                  const SizedBox(height: 20),
                  // Personal Information
                  PersonalInfoSection(
                    attendee: attendee,
                    databaseService: databaseService,
                  ),
                  const SizedBox(height: 20),
                  // Contact Information
                  ContactInfoSection(
                    attendee: attendee,
                    onEmailTap: _launchEmail,
                    onPhoneTap: _launchPhone,
                  ),
                  const SizedBox(height: 20),
                  // Professional Information
                  ProfessionalInfoSection(
                    attendee: attendee,
                    onWebsiteTap: _launchUrl,
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  ActionButtons(onEditProfile: _editProfile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Build attendee stats overview widget with accurate calculation
  Widget _buildAttendeeStatsOverview(
    Attendee attendee,
    DatabaseService databaseService,
  ) {
    return FutureBuilder<AttendeeStats>(
      future: _calculateAccurateStats(attendee, databaseService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Center(
                child: SpinKitThreeBounce(
                  color: AppConstants.primaryColor,
                  size: 20.0,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: Text('Failed to load stats')),
          );
        }

        final stats = snapshot.data;
        if (stats == null) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(child: Text('No stats available')),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Statistics', style: AppConstants.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Registered',
                      stats.registeredEvents.toString(),
                      Icons.event_available,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Attended',
                      stats.attendedEvents.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Upcoming',
                      stats.upcomingEvents.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Missed',
                      stats.notAttendedEvents.toString(),
                      Icons.cancel,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Calculate accurate stats using the same logic as dashboard
  Future<AttendeeStats> _calculateAccurateStats(
    Attendee attendee,
    DatabaseService databaseService,
  ) async {
    try {
      // Get current user ID from auth
      final currentUser = databaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final currentUserId = currentUser.uid;

      // Load user registrations
      final myRegistrations = await databaseService.getUserRegistrations(
        currentUserId,
      );

      // Get events for which user is registered
      List<Event> myRegisteredEvents = [];
      if (myRegistrations.isNotEmpty) {
        // Extract unique event IDs from registrations
        final eventIds =
            myRegistrations.map((reg) => reg.eventId).toSet().toList();

        // Fetch events directly from database
        for (String eventId in eventIds) {
          try {
            final event = await databaseService.getEventById(eventId);
            if (event != null) {
              myRegisteredEvents.add(event);
            }
          } catch (e) {
            debugPrint('Error fetching event $eventId: $e');
          }
        }
      }

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

      return attendeeStats;
    } catch (e) {
      debugPrint('Error calculating stats: $e');
      // Return empty stats on error
      return AttendeeStats(
        registeredEvents: 0,
        attendedEvents: 0,
        notAttendedEvents: 0,
        upcomingEvents: 0,
      );
    }
  }

  // Build individual stat card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppConstants.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Ensure loading overlay is hidden when widget is disposed
    if (_isLoading) {
      LoadingOverlay.hide();
    }
    super.dispose();
  }

  // Add refresh method
  Future<void> _refreshProfile() async {
    setState(() {
      _streamBuilderKey = UniqueKey(); // Generate new key to force rebuild
    });

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfile()),
    );
  }

  void _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Hello from MegaVent',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('Could not launch email client');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening email: ${e.toString()}');
    }
  }

  void _launchPhone(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not launch phone dialer');
      }
    } catch (e) {
      _showErrorSnackBar('Error making call: ${e.toString()}');
    }
  }

  void _launchUrl(String url) async {
    try {
      // Ensure URL has a scheme
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch website');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening website: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
