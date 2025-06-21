import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class ActionButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController capacityController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final String? posterUrl; // Make this a required parameter
  final VoidCallback onClearForm;
  final VoidCallback onCreateEvent;

  const ActionButtons({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.locationController,
    required this.capacityController,
    required this.startTimeController,
    required this.endTimeController,
    required this.posterUrl, // Add this as required
    required this.onClearForm,
    required this.onCreateEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppConstants.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Clear Form',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onCreateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Event',
              style: AppConstants.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}