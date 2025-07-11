import 'package:flutter/material.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/dashboard/admin_empty_state.dart';
import 'package:megavent/utils/admin/dashboard/time_utils.dart';

class AdminRegistrationsSection extends StatelessWidget {
  final List<Registration> registrations;
  final VoidCallback onViewAll;

  const AdminRegistrationsSection({
    super.key,
    required this.registrations,
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
              'Recent Registrations (${registrations.length})',
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
          child: registrations.isEmpty
              ? const AdminEmptyState(
                  message: 'No registrations yet',
                  icon: Icons.how_to_reg,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: registrations.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final registration = registrations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppConstants.warningColor.withOpacity(0.1),
                        child: Icon(
                          Icons.how_to_reg,
                          color: AppConstants.warningColor,
                        ),
                      ),
                      title: Text(
                        'Registration #${registration.id}',
                        style: AppConstants.titleMedium,
                      ),
                      subtitle: Text(
                        'Event: ${registration.eventId} • User: ${registration.userId}',
                        style: AppConstants.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: registration.hasAttended
                                  ? AppConstants.successColor
                                  : AppConstants.warningColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              registration.hasAttended ? 'Attended' : 'Pending',
                              style: AppConstants.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeUtils.getTimeAgo(registration.registeredAt),
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