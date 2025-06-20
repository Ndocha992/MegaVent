import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';
import 'package:megavent/data/fake_data.dart';

class StaffList extends StatelessWidget {
  final List<Staff> staffList;
  final Function(Staff) onStaffTap;
  final VoidCallback onAddStaff;
  final String searchQuery;

  const StaffList({
    super.key,
    required this.staffList,
    required this.onStaffTap,
    required this.onAddStaff,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (staffList.isEmpty) {
      return StaffEmptyState(searchQuery: searchQuery, onAddStaff: onAddStaff);
    }

    return Container(
      color: AppConstants.backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StaffCard(
              staff: staffList[index],
              onTap: () => onStaffTap(staffList[index]),
            ),
          );
        },
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback onTap;

  const StaffCard({super.key, required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppConstants.cardDecoration.copyWith(
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              StaffAvatar(staff: staff),
              const SizedBox(width: 16),
              Expanded(child: StaffInfo(staff: staff)),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaffAvatar extends StatelessWidget {
  final Staff staff;

  const StaffAvatar({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _getDepartmentColor(staff.department).withOpacity(0.8),
                _getDepartmentColor(staff.department),
              ],
            ),
          ),
          child:
              staff.profileUrl.isNotEmpty
                  ? ClipOval(
                    child: Image.network(
                      staff.profileUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildInitialsAvatar(),
                    ),
                  )
                  : _buildInitialsAvatar(),
        ),
        if (staff.isNew)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppConstants.successColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
              ),
              child: const Icon(Icons.fiber_new, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        StaffUtils.getInitials(staff.name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    return StaffUtils.getDepartmentColor(department);
  }
}

class StaffInfo extends StatelessWidget {
  final Staff staff;

  const StaffInfo({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                staff.name,
                style: AppConstants.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            StaffDepartmentChip(department: staff.department),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          staff.role,
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        StaffInfoRow(icon: Icons.email_outlined, text: staff.email),
        const SizedBox(height: 4),
        StaffInfoRow(
          icon: Icons.access_time,
          text: 'Hired ${StaffUtils.formatHireDate(staff.hiredAt)}',
        ),
      ],
    );
  }
}

class StaffDepartmentChip extends StatelessWidget {
  final String department;

  const StaffDepartmentChip({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDepartmentColor(department).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        department,
        style: AppConstants.bodySmall.copyWith(
          color: _getDepartmentColor(department),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    return StaffUtils.getDepartmentColor(department);
  }
}

class StaffInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const StaffInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class StaffEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback onAddStaff;

  const StaffEmptyState({
    super.key,
    required this.searchQuery,
    required this.onAddStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No staff found',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'Start by adding your first staff member',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddStaff,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
