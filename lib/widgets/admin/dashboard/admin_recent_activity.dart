import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class AdminRecentActivity extends StatelessWidget {
  final List<Event> events;
  final List<Organizer> organizers;
  final List<Registration> registrations;

  const AdminRecentActivity({
    super.key,
    required this.events,
    required this.organizers,
    required this.registrations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child: _getRecentActivities().isEmpty
              ? _buildEmptyActivityState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getRecentActivities().length,
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
                      title: Text(
                        activity['title'],
                        style: AppConstants.titleMedium,
                      ),
                      subtitle: Text(
                        activity['time'],
                        style: AppConstants.bodySmall,
                      ),
                      trailing: activity['isNew']
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
    for (final event in events.take(2)) {
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
    for (final organizer in organizers.take(2)) {
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
    for (final registration in registrations.take(2)) {
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

  bool _isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 6;
  }
}