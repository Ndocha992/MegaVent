import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class EditEventActions extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool isLoading; // Add this required parameter
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditEventActions({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.isLoading, // Add this to constructor
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel, // Disable when loading
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppConstants.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave, // Disable when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Changes',
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