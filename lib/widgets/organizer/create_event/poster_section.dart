import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/create_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/create_event/section_container.dart';

class PosterSection extends StatelessWidget {
  final TextEditingController posterUrlController;
  final VoidCallback onPosterUrlChanged;

  const PosterSection({
    super.key,
    required this.posterUrlController,
    required this.onPosterUrlChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Event Poster',
      icon: Icons.image_outlined,
      children: [
        CustomTextField(
          controller: posterUrlController,
          label: 'Poster URL (Optional)',
          hint: 'Enter poster image URL',
          prefixIcon: Icons.link,
          onChanged: (_) => onPosterUrlChanged(),
        ),
        const SizedBox(height: 12),
        _buildPosterPreview(),
      ],
    );
  }

  Widget _buildPosterPreview() {
    if (posterUrlController.text.isNotEmpty) {
      return Container(
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
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.borderColor,
            style: BorderStyle.solid,
          ),
          color: AppConstants.backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Add poster URL to preview',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }
  }
}
