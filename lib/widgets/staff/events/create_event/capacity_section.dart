import 'package:flutter/material.dart';
import 'package:megavent/widgets/organizer/events/create_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/events/create_event/section_container.dart';

class CapacitySection extends StatelessWidget {
  final TextEditingController capacityController;

  const CapacitySection({
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
            if (int.parse(value) <= 0) {
              return 'Capacity must be greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }
}