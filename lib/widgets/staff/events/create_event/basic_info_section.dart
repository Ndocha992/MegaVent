import 'package:flutter/material.dart';
import 'package:megavent/widgets/organizer/events/create_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/events/create_event/section_container.dart';

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        CustomTextField(
          controller: nameController,
          label: 'Event Name',
          hint: 'Enter event name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: descriptionController,
          label: 'Description',
          hint: 'Enter event description',
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event description';
            }
            return null;
          },
        ),
      ],
    );
  }
}