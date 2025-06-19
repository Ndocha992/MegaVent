import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/edit_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/edit_event/section_container.dart';

class EditEventPoster extends StatelessWidget {
  final TextEditingController posterUrlController;

  const EditEventPoster({
    super.key,
    required this.posterUrlController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Event Poster',
      icon: Icons.image_outlined,
      children: [
        CustomTextField(
          controller: posterUrlController,
          label: 'Poster URL',
          hint: 'Enter poster image URL',
          prefixIcon: Icons.link,
        ),
        const SizedBox(height: 12),
        if (posterUrlController.text.isNotEmpty)
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                posterUrlController.text,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppConstants.backgroundColor,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}