import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class RecentActivitySection extends StatelessWidget {
  final List<Registration> myRegistrations;
  final Map<String, Event> eventCache;

  const RecentActivitySection({
    super.key,
    required this.myRegistrations,
    required this.eventCache,
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
          child: myRegistrations.isEmpty
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

  List<Map<String, dynamic>> _getRecentActivities() {
    if (myRegistrations.isEmpty) {
      return [];
    }

    List<Map<String, dynamic>> activities = [];

    // Add registration activities
    for (final registration in myRegistrations.take(5)) {
      final event = eventCache[registration.eventId];
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
}