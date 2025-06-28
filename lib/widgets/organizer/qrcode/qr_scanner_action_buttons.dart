import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';

class QRScannerActionButtons extends StatelessWidget {
  final Event? selectedEvent;
  final VoidCallback onResetScanner;
  final VoidCallback onManualEntry;

  const QRScannerActionButtons({
    super.key,
    required this.selectedEvent,
    required this.onResetScanner,
    required this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onResetScanner,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text(
              'Reset Scanner',
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: AppConstants.textSecondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: selectedEvent != null ? onManualEntry : null,
            icon: const Icon(Icons.keyboard, size: 18),
            label: const Text(
              'Manual Entry',
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12), // Reduced padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }
}