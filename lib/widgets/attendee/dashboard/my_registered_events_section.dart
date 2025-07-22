import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/attendee/event_helpers.dart';

class MyRegisteredEventsSection extends StatelessWidget {
  final List<Registration> myRegistrations;
  final Map<String, Event> eventCache;
  final VoidCallback onViewAll;
  final Function(Event) onEventTap;

  const MyRegisteredEventsSection({
    super.key,
    required this.myRegistrations,
    required this.eventCache,
    required this.onViewAll,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Registered Events', style: AppConstants.headlineSmall),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        myRegistrations.isEmpty
            ? _buildEmptyEventsState(
              'You haven\'t registered for any events yet',
            )
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myRegistrations.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final registration = myRegistrations[index];
                final event = eventCache[registration.eventId];
                if (event == null) return const SizedBox.shrink();
                return _buildMyEventTile(event, registration);
              },
            ),
      ],
    );
  }

  Widget _buildMyEventTile(Event event, Registration registration) {
    final now = DateTime.now();
    final eventStart = EventHelpers.getEventStartDateTime(event);
    final eventEnd = EventHelpers.getEventEndDateTime(event);

    // Improved event status determination
    String statusText;
    Color statusColor;
    bool isUpcoming = false;
    bool hasEnded = false;
    bool isOngoing = false;

    if (registration.attended) {
      statusText = 'Attended';
      statusColor = AppConstants.successColor;
    } else if (eventEnd.isBefore(now)) {
      statusText = 'Ended';
      statusColor = AppConstants.errorColor;
      hasEnded = true;
    } else if (eventStart.isAfter(now)) {
      statusText = 'Upcoming';
      statusColor = AppConstants.accentColor;
      isUpcoming = true;
    } else if (eventStart.isBefore(now) && eventEnd.isAfter(now)) {
      statusText = 'Ongoing';
      statusColor = AppConstants.primaryColor;
      isOngoing = true;
    } else {
      statusText = 'Registered';
      statusColor = AppConstants.primaryColor;
    }

    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppConstants.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isUpcoming || isOngoing
                          ? AppConstants.primaryGradient
                          : hasEnded
                          ? [Colors.grey.shade400, Colors.grey.shade600]
                          : AppConstants.primaryGradient,
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
                    style: const TextStyle(color: Colors.white, fontSize: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statusText,
                style: AppConstants.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event, size: 48, color: AppConstants.primaryColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
