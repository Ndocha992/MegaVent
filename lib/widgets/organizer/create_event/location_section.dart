import 'package:flutter/material.dart';
import 'package:megavent/widgets/organizer/create_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/create_event/section_container.dart';

class LocationSection extends StatelessWidget {
  final TextEditingController locationController;

  const LocationSection({
    super.key,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        CustomTextField(
          controller: locationController,
          label: 'Venue',
          hint: 'Enter event venue',
          prefixIcon: Icons.place,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter event location';
            }
            return null;
          },
        ),
      ],
    );
  }
}