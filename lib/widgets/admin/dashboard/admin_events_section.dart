import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/dashboard/admin_empty_state.dart';
import 'package:megavent/utils/admin/dashboard/time_utils.dart';

class AdminEventsSection extends StatelessWidget {
  final List<Event> events;
  final VoidCallback onViewAll;

  const AdminEventsSection({
    super.key,
    required this.events,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Events (${events.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child: events.isEmpty
              ? const AdminEmptyState(
                  message: 'No events yet',
                  icon: Icons.event,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
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
                        '${event.location} • ${TimeUtils.formatDate(event.startDate)}',
                        style: AppConstants.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            TimeUtils.getTimeAgo(event.createdAt),
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
}