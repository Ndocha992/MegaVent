import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/organizer/create_staff.dart';
import 'package:megavent/screens/organizer/staff_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';

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
          child:
              staff.isEmpty
                  ? _buildEmptyStaffState(context)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: staff.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final staffMember = staff[index];
                      return GestureDetector(
                        onTap: () => _onStaffTap(context, staffMember),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: _buildStaffAvatar(staffMember),
                          title: Text(
                            staffMember.fullName, // Using fullName from model
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
                                    color: StaffUtils.getDepartmentColor(
                                      staffMember.department,
                                    ),
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

  Widget _buildEmptyStaffState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Staff Members Yet',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first staff member to get started',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateStaff()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
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
                StaffUtils.getDepartmentColor(
                  staffMember.department,
                ).withOpacity(0.8),
                StaffUtils.getDepartmentColor(staffMember.department),
              ],
            ),
          ),
          child: _buildProfileImage(staffMember),
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

  Widget _buildProfileImage(Staff staffMember) {
    // Handle different types of profile images
    if (staffMember.profileImage != null &&
        staffMember.profileImage!.isNotEmpty) {
      // Check if it's a base64 encoded image
      if (staffMember.profileImage!.startsWith('data:image/')) {
        return _buildBase64Image(staffMember);
      }
      // Check if it's a base64 string without prefix
      else if (_isBase64String(staffMember.profileImage!)) {
        return _buildBase64ImageFromString(staffMember);
      }
      // Handle network images
      else if (staffMember.profileImage!.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            staffMember.profileImage!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    _buildInitialsAvatar(staffMember),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: AppConstants.primaryColor,
                    size: 20.0,
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    // Default to initials avatar
    return _buildInitialsAvatar(staffMember);
  }

  Widget _buildBase64Image(Staff staffMember) {
    try {
      // Extract base64 data from data URL
      final base64Data = staffMember.profileImage!.split(',')[1];
      final bytes = base64Decode(base64Data);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildInitialsAvatar(staffMember),
        ),
      );
    } catch (e) {
      return _buildInitialsAvatar(staffMember);
    }
  }

  Widget _buildBase64ImageFromString(Staff staffMember) {
    try {
      final bytes = base64Decode(staffMember.profileImage!);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildInitialsAvatar(staffMember),
        ),
      );
    } catch (e) {
      return _buildInitialsAvatar(staffMember);
    }
  }

  Widget _buildInitialsAvatar(Staff staffMember) {
    return Center(
      child: Text(
        StaffUtils.getInitials(staffMember.fullName), // Using fullName
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  bool _isBase64String(String str) {
    try {
      // Basic check for base64 string
      final regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return regex.hasMatch(str) && str.length % 4 == 0;
    } catch (e) {
      return false;
    }
  }

  void _onStaffTap(BuildContext context, Staff staff) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StaffDetails(staff: staff)),
    );
  }
}
