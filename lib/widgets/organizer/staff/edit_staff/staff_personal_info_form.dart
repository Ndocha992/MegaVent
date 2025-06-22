import 'package:flutter/material.dart';
import 'package:megavent/utils/organizer/staff/etit_staff/staff_utils.dart';

class StaffPersonalInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback? onNameChanged;

  const StaffPersonalInfoForm({
    super.key,
    required this.nameController,
    this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaffFormField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          onChanged: (value) {
            // Call the callback when name changes to update initials
            onNameChanged?.call();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter full name';
            }
            return null;
          },
        ),
      ],
    );
  }
}