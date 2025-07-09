import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';

class StaffManualEntryDialog extends StatelessWidget {
  final Event? selectedEvent;
  final Function(String, String) onCheckIn;

  const StaffManualEntryDialog({
    super.key,
    required this.selectedEvent,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController attendeeIdController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppConstants.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.keyboard, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Manual Check-in'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: AppConstants.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedEvent?.name ?? 'None selected',
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: attendeeIdController,
              decoration: InputDecoration(
                labelText: 'Attendee ID *',
                hintText: 'Enter attendee ID from QR code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppConstants.primaryColor,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the attendee ID to manually check them in',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final attendeeId = attendeeIdController.text.trim();
            if (attendeeId.isNotEmpty) {
              Navigator.of(context).pop();
              onCheckIn(attendeeId, selectedEvent!.id);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Check In'),
        ),
      ],
    );
  }
}
