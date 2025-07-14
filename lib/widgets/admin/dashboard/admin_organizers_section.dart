import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/dashboard/organizer_avatar.dart';
import 'package:megavent/widgets/admin/dashboard/admin_empty_state.dart';
import 'package:megavent/utils/admin/dashboard/time_utils.dart';

class AdminOrganizersSection extends StatelessWidget {
  final List<Organizer> organizers;
  final VoidCallback onViewAll;
  final Function(Organizer) onOrganizerTap;

  const AdminOrganizersSection({
    super.key,
    required this.organizers,
    required this.onViewAll,
    required this.onOrganizerTap,
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
              'Recent Organizers (${organizers.length})',
              style: AppConstants.headlineSmall,
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              organizers.isEmpty
                  ? const AdminEmptyState(
                    message: 'No organizers yet',
                    icon: Icons.business,
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: organizers.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final organizer = organizers[index];
                      return ListTile(
                        leading: OrganizerAvatar(organizer: organizer),
                        title: Text(
                          organizer.fullName,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          organizer.email,
                          style: AppConstants.bodySmall,
                        ),
                        onTap: () => onOrganizerTap(organizer),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              TimeUtils.getTimeAgo(organizer.createdAt),
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
