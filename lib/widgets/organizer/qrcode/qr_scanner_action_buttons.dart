import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';

class QRScannerActionButtons extends StatelessWidget {
  final Event? selectedEvent;
  final VoidCallback onResetScanner;

  const QRScannerActionButtons({
    super.key,
    required this.selectedEvent,
    required this.onResetScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onResetScanner,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Scanner', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ), // Reduced padding
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
