import 'package:flutter/material.dart';
import 'package:megavent/utils/organizer/staff/etit_staff/staff_utils.dart';

class StaffPersonalInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController profileUrlController;

  const StaffPersonalInfoForm({
    super.key,
    required this.nameController,
    required this.profileUrlController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaffFormField(
          controller: nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        StaffFormField(
          controller: profileUrlController,
          label: 'Profile Image URL (Optional)',
          icon: Icons.image_outlined,
          maxLines: 2,
        ),
      ],
    );
  }
}