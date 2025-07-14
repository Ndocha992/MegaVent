import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/dashboard/admin_empty_state.dart';
import 'package:megavent/utils/admin/dashboard/time_utils.dart';

class AdminStaffSection extends StatelessWidget {
  final List<Staff> staff;

  const AdminStaffSection({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Staff (${staff.length})',
              style: AppConstants.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              staff.isEmpty
                  ? const AdminEmptyState(
                    message: 'No staff yet',
                    icon: Icons.people,
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: staff.take(5).length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final staffMember = staff[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppConstants.accentColor.withOpacity(
                            0.1,
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppConstants.accentColor,
                          ),
                        ),
                        title: Text(
                          staffMember.name,
                          style: AppConstants.titleMedium,
                        ),
                        subtitle: Text(
                          '${staffMember.email} • ${staffMember.role}',
                          style: AppConstants.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              TimeUtils.getTimeAgo(staffMember.hiredAt),
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
