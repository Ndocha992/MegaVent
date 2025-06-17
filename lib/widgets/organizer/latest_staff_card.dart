import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

class LatestStaffCard extends StatelessWidget {
  final List<Staff> staff;

  const LatestStaffCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Staff', style: AppConstants.headlineSmall),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staff.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final staffMember = staff[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppConstants.primaryColor.withOpacity(
                        0.1,
                      ),
                      child: Text(
                        staffMember.name
                            .split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join()
                            .toUpperCase(),
                        style: AppConstants.titleMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (staffMember.isNew)
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
                title: Text(
                  staffMember.name,
                  style: AppConstants.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      staffMember.role,
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staffMember.department,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staffMember.email,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
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
                        color: _getDepartmentColor(
                          staffMember.department,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        staffMember.department,
                        style: AppConstants.bodySmall.copyWith(
                          color: _getDepartmentColor(staffMember.department),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatHireDate(staffMember.hiredAt),
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

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'operations':
        return AppConstants.primaryColor;
      case 'creative':
        return AppConstants.secondaryColor;
      case 'it':
        return AppConstants.accentColor;
      case 'hr':
        return AppConstants.warningColor;
      case 'finance':
        return AppConstants.successColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  String _formatHireDate(DateTime hiredAt) {
    final now = DateTime.now();
    final difference = now.difference(hiredAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${hiredAt.day}/${hiredAt.month}/${hiredAt.year}';
    }
  }
}
