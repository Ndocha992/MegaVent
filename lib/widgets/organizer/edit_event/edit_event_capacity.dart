import 'package:flutter/material.dart';
import 'package:megavent/widgets/organizer/edit_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/edit_event/section_container.dart';

class EditEventCapacity extends StatelessWidget {
  final TextEditingController capacityController;

  const EditEventCapacity({
    super.key,
    required this.capacityController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Capacity',
      icon: Icons.people_outline,
      children: [
        CustomTextField(
          controller: capacityController,
          label: 'Maximum Attendees',
          hint: 'Enter maximum capacity',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.people,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event capacity';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }
}