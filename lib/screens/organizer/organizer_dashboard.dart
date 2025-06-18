import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/latest_attendees_card.dart';
import 'package:megavent/widgets/organizer/latest_events_card.dart';
import 'package:megavent/widgets/organizer/latest_staff_card.dart';
import 'package:megavent/widgets/organizer/quick_actions_grid.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/stats_overview.dart';
import 'package:megavent/widgets/organizer/welcome_card.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: OrganizerAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: OrganizerSidebar(currentRoute: '/organizer-dashboard'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeCard(),
            const SizedBox(height: 24),
            StatsOverview(stats: FakeData.dashboardStats),
            const SizedBox(height: 24),
            LatestEventsCard(events: FakeData.getLatestEvents()),
            const SizedBox(height: 24),
            LatestAttendeesCard(attendees: FakeData.getLatestAttendees()),
            const SizedBox(height: 24),
            LatestStaffCard(staff: FakeData.getLatestStaff()),
            const SizedBox(height: 24),
            QuickActionsGrid(
              onNavigate: (route) {
                Navigator.of(context).pushReplacementNamed(route);
              },
            ),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
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
                title: Text(activity['title'], style: AppConstants.titleMedium),
                subtitle: Text(activity['time'], style: AppConstants.bodySmall),
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
    final upcomingEvents =
        FakeData.events
            .where((event) => event.startDate.isAfter(DateTime.now()))
            .take(3)
            .toList();

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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: upcomingEvents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final event = upcomingEvents[index];
            return Container(
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
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    return [
      {
        'title': 'New attendee registered for Tech Conference',
        'time': '2 minutes ago',
        'icon': Icons.person_add,
        'color': AppConstants.successColor,
        'isNew': true,
      },
      {
        'title': 'Staff member Alice joined Operations team',
        'time': '1 hour ago',
        'icon': Icons.badge,
        'color': AppConstants.primaryColor,
        'isNew': true,
      },
      {
        'title': 'Event "Music Festival" capacity updated',
        'time': '3 hours ago',
        'icon': Icons.edit,
        'color': AppConstants.warningColor,
        'isNew': false,
      },
      {
        'title': 'QR code scanned for Business Summit',
        'time': '5 hours ago',
        'icon': Icons.qr_code,
        'color': AppConstants.accentColor,
        'isNew': false,
      },
      {
        'title': 'New event "Art Exhibition" created',
        'time': '1 day ago',
        'icon': Icons.event,
        'color': AppConstants.secondaryColor,
        'isNew': false,
      },
    ];
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
