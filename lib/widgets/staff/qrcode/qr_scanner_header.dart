import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart';

class QRScannerHeader extends StatelessWidget {
  final List<Event> availableEvents;
  final Event? selectedEvent;
  final Function(Event?) onEventChanged;

  const QRScannerHeader({
    super.key,
    required this.availableEvents,
    required this.selectedEvent,
    required this.onEventChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Slightly smaller
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 20, // Smaller icon
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Check-in',
                      style: AppConstants.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Slightly smaller
                      ),
                    ),
                    Text(
                      'Scan QR codes to check in attendees',
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 13, // Smaller font
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (availableEvents.isNotEmpty) ...[
            const SizedBox(height: 16), // Reduced spacing
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, color: AppConstants.primaryColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Selected Event:',
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                ),
              ),
              child: DropdownButton<Event>(
                value: selectedEvent,
                dropdownColor: Colors.white,
                style: AppConstants.bodyMedium.copyWith(fontSize: 14),
                underline: Container(),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppConstants.primaryColor,
                ),
                items: availableEvents.map((event) {
                  return DropdownMenuItem<Event>(
                    value: event,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.name,
                          style: AppConstants.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          event.location,
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onEventChanged,
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No active events available for check-in',
                      style: AppConstants.bodyMedium.copyWith(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}