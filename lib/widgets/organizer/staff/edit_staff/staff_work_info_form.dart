import 'package:flutter/material.dart';
import 'package:megavent/utils/organizer/staff/etit_staff/staff_dropdown_field.dart';
import 'package:megavent/utils/organizer/staff/etit_staff/staff_switch_tile.dart';

class StaffWorkInfoForm extends StatelessWidget {
  final String? selectedRole;
  final String? selectedDepartment;
  final bool isNew;
  final List<String> roles;
  final List<String> departments;
  final void Function(String?) onRoleChanged;
  final void Function(String?) onDepartmentChanged;
  final void Function(bool) onIsNewChanged;

  const StaffWorkInfoForm({
    super.key,
    required this.selectedRole,
    required this.selectedDepartment,
    required this.isNew,
    required this.roles,
    required this.departments,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onIsNewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaffDropdownField(
          value: selectedRole,
          label: 'Role',
          icon: Icons.work_outline,
          items: roles,
          onChanged: onRoleChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a role';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        StaffDropdownField(
          value: selectedDepartment,
          label: 'Department',
          icon: Icons.business_outlined,
          items: departments,
          onChanged: onDepartmentChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        StaffSwitchTile(
          value: isNew,
          onChanged: onIsNewChanged,
          title: 'New Staff Member',
          subtitle: 'Mark as new to show "NEW" badge',
          icon: Icons.new_releases_outlined,
        ),
      ],
    );
  }
}