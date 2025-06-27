import 'package:flutter/material.dart';
import 'package:megavent/utils/organizer/staff/etit_staff/staff_utils.dart';

class StaffContactInfoForm extends StatelessWidget {
  final TextEditingController phoneController;

  const StaffContactInfoForm({super.key, required this.phoneController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaffFormField(
          controller: phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
