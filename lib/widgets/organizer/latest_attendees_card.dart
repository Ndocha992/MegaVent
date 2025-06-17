import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

class LatestAttendeesCard extends StatelessWidget {
  final List<Attendee> attendees;

  const LatestAttendeesCard({super.key, required this.attendees});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Attendees', style: AppConstants.headlineSmall),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendees.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final attendee = attendees[index];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppConstants.primaryColor.withOpacity(
                        0.1,
                      ),
                      child: Text(
                        attendee.name.substring(0, 1).toUpperCase(),
                        style: AppConstants.titleMedium.copyWith(
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    if (attendee.isNew)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppConstants.successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(attendee.name, style: AppConstants.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(attendee.eventName, style: AppConstants.bodySmall),
                    Text(attendee.email, style: AppConstants.bodySmall),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        attendee.hasAttended
                            ? AppConstants.successColor.withOpacity(0.1)
                            : AppConstants.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    attendee.hasAttended ? 'Attended' : 'Registered',
                    style: AppConstants.bodySmall.copyWith(
                      color:
                          attendee.hasAttended
                              ? AppConstants.successColor
                              : AppConstants.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
