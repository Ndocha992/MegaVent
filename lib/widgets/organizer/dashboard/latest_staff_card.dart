import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/staff_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/organizer-staff');
              },
              child: const Text('View All'),
            ),
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
              return GestureDetector(
                onTap: () => _onStaffTap(context, staffMember),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _buildStaffAvatar(staffMember),
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
                          color: StaffUtils.getDepartmentColor(
                            staffMember.department,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          staffMember.department,
                          style: AppConstants.bodySmall.copyWith(
                            color: StaffUtils.getDepartmentColor(staffMember.department),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        StaffUtils.formatHireDate(staffMember.hiredAt),
                        style: AppConstants.bodySmall.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffAvatar(Staff staffMember) {
    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                StaffUtils.getDepartmentColor(staffMember.department).withOpacity(0.8),
                StaffUtils.getDepartmentColor(staffMember.department),
              ],
            ),
          ),
          child: staffMember.profileImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    staffMember.profileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(staffMember),
                  ),
                )
              : _buildInitialsAvatar(staffMember),
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
                boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar(Staff staffMember) {
    return Center(
      child: Text(
        StaffUtils.getInitials(staffMember.name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _onStaffTap(BuildContext context, Staff staff) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StaffDetails(staff: staff)),
    );
  }
}