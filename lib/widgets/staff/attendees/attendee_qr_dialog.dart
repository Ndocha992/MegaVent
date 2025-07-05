import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:intl/intl.dart';

class AttendeeQRDialog extends StatelessWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;

  const AttendeeQRDialog({
    super.key,
    required this.attendee,
    this.registration,
    required this.eventName,
  });

  bool _isBase64(String value) {
    try {
      base64Decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Getters that use registration data when available
  bool get hasAttended {
    return registration?.hasAttended ?? false;
  }

  DateTime get registeredAt {
    return registration?.registeredAt ?? attendee.createdAt;
  }

  String get attendanceStatus {
    if (!attendee.isApproved) return 'Pending Approval';
    return hasAttended ? 'Attended' : 'Registered';
  }

  String get eventId {
    return registration?.eventId ?? 'Unknown';
  }

  String get qrCode {
    return registration?.qrCode ?? 'No QR Code';
  }

  Widget _buildAttendeeAvatar() {
    // Handle different image sources
    if (attendee.profileImage != null && attendee.profileImage!.isNotEmpty) {
      // Check if it's base64 data
      if (_isBase64(attendee.profileImage!)) {
        return ClipOval(
          child: Image.memory(
            base64Decode(attendee.profileImage!),
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            errorBuilder:
                (context, error, stackTrace) => _buildInitialsAvatar(),
          ),
        );
      } else {
        // It's a regular URL
        return ClipOval(
          child: Image.network(
            attendee.profileImage!,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            errorBuilder:
                (context, error, stackTrace) => _buildInitialsAvatar(),
          ),
        );
      }
    } else {
      // No image, show initials
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor:
          hasAttended ? AppConstants.successColor : AppConstants.primaryColor,
      child: Text(
        _getAttendeeInitials(attendee.fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getAttendeeInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else {
      return 'U';
    }
  }

  String _getFormattedRegistrationDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy \'at\' HH:mm');
    return formatter.format(date);
  }

  Widget _buildQRCode() {
    final qrData = qrCode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            'QR Code Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 150.0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Data: $qrData',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // Profile Avatar with image or initials
                _buildAttendeeAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              attendee.fullName,
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

            // Event Information
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
                    'Event Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Event', eventName),
                  _buildDetailRow('Event ID', eventId),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Attendee Details Section
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
                  _buildDetailRow('Full Name', attendee.fullName),
                  _buildDetailRow('Email', attendee.email),
                  _buildDetailRow('Phone', attendee.phone),
                  _buildDetailRow(
                    'Status',
                    attendanceStatus,
                    statusColor:
                        hasAttended ? AppConstants.successColor : Colors.orange,
                  ),
                  _buildDetailRow(
                    'Approved',
                    attendee.isApproved ? 'Yes' : 'No',
                    statusColor:
                        attendee.isApproved
                            ? AppConstants.successColor
                            : AppConstants.errorColor,
                  ),
                  _buildDetailRow(
                    'Registered',
                    _getFormattedRegistrationDate(registeredAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // QR Code Section - Now shows actual QR code
            _buildQRCode(),
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

// Updated helper function to show the QR dialog
void showAttendeeQRDialog(
  BuildContext context,
  Attendee attendee,
  Registration? registration,
  String eventName,
) {
  showDialog(
    context: context,
    builder:
        (context) => AttendeeQRDialog(
          attendee: attendee,
          registration: registration,
          eventName: eventName,
        ),
  );
}
