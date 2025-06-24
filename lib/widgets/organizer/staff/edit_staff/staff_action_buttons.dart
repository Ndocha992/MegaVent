import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffActionButtons extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isLoading; // Add this parameter

  const StaffActionButtons({
    super.key,
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false, // Add this with default value
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
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave, // Disable when loading
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Updating...' : 'Adding...',
                        style: AppConstants.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    isEditing ? 'Update Staff' : 'Add Staff',
                    style: AppConstants.bodyMedium.copyWith(
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