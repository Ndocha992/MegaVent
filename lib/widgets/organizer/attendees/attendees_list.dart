import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

class AttendeesList extends StatelessWidget {
  final List<Attendee> attendeesList;
  final Function(Attendee) onAttendeeTap;
  final Function(Attendee) onShowQR;
  final String searchQuery;

  const AttendeesList({
    super.key,
    required this.attendeesList,
    required this.onAttendeeTap,
    required this.onShowQR,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (attendeesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.group_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'No attendees found matching "$searchQuery"'
                  : 'No attendees found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendeesList.length,
      itemBuilder: (context, index) {
        final attendee = attendeesList[index];
        return AttendeeCard(
          attendee: attendee,
          onTap: () => onAttendeeTap(attendee),
          onShowQR: () => onShowQR(attendee),
        );
      },
    );
  }
}

class AttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final VoidCallback onTap;
  final VoidCallback onShowQR;

  const AttendeeCard({
    super.key,
    required this.attendee,
    required this.onTap,
    required this.onShowQR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: attendee.hasAttended
                      ? AppConstants.successColor
                      : AppConstants.primaryColor,
                  child: Text(
                    attendee.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              attendee.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (attendee.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendee.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        attendee.phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            attendee.hasAttended
                                ? Icons.check_circle
                                : Icons.access_time,
                            size: 16,
                            color: attendee.hasAttended
                                ? AppConstants.successColor
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            attendee.hasAttended ? 'Attended' : 'Not Attended',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: attendee.hasAttended
                                  ? AppConstants.successColor
                                  : Colors.orange,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Registered ${_formatDate(attendee.registeredAt)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: onShowQR,
                  icon: const Icon(Icons.qr_code),
                  color: AppConstants.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}