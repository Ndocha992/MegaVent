import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/dashboard/admin_empty_state.dart';
import 'package:megavent/utils/admin/dashboard/time_utils.dart';

class AdminAttendeesSection extends StatelessWidget {
  final List<Attendee> attendees;

  const AdminAttendeesSection({super.key, required this.attendees});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Attendees (${attendees.length})',
              style: AppConstants.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              attendees.isEmpty
                  ? const AdminEmptyState(
                    message: 'No attendees yet',
                    icon: Icons.person,
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attendees.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final attendee = attendees[index];
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
                              TimeUtils.getTimeAgo(attendee.createdAt),
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
}
