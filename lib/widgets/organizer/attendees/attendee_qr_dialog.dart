import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/organizer/attendees/attendees_utils.dart';

class AttendeeQRDialog extends StatelessWidget {
  final Attendee attendee;

  const AttendeeQRDialog({super.key, required this.attendee});

  @override
  Widget build(BuildContext context) {
    AttendeesUtils.generateQRData(attendee);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      attendee.hasAttended
                          ? AppConstants.successColor
                          : AppConstants.primaryColor,
                  child: Text(
                    AttendeesUtils.getAttendeeInitials(attendee.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              attendee.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        attendee.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // User Details Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendee Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Email', attendee.email),
                  _buildDetailRow('Phone', attendee.phone),
                  _buildDetailRow('QR Code', attendee.qrCode),
                  _buildDetailRow(
                    'Status',
                    attendee.hasAttended ? 'Attended' : 'Not Attended',
                    statusColor:
                        attendee.hasAttended
                            ? AppConstants.successColor
                            : Colors.orange,
                  ),
                  _buildDetailRow(
                    'Registered',
                    AttendeesUtils.getFormattedRegistrationDate(
                      attendee.registeredAt,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: statusColor ?? AppConstants.textSecondaryColor,
                fontWeight:
                    statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the QR dialog
void showAttendeeQRDialog(BuildContext context, Attendee attendee) {
  showDialog(
    context: context,
    builder: (context) => AttendeeQRDialog(attendee: attendee),
  );
}
