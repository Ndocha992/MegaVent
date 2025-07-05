import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class EventAttendanceStatusSection extends StatelessWidget {
  final Registration? registration;

  const EventAttendanceStatusSection({super.key, this.registration});

  // Getters that use registration data when available
  bool get hasAttended {
    return registration?.hasAttended ?? false;
  }

  DateTime? get registrationDate {
    return registration?.registeredAt;
  }

  String get qrCode {
    return registration?.qrCode ?? 'No QR Code';
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
      child: Center(
        child: Column(
          children: [
            Text(
              'Event QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan this code for attendance',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance Status', style: AppConstants.titleLarge),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(hasAttended).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasAttended
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  color: _getStatusColor(hasAttended),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(hasAttended).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  hasAttended ? Icons.check_circle : Icons.schedule,
                  color: _getStatusColor(hasAttended),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Status',
                        style: TextStyle(
                          color: _getStatusColor(hasAttended),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        hasAttended ? 'Present' : 'Not Marked',
                        style: TextStyle(
                          color: _getStatusColor(hasAttended).withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        hasAttended
                            ? 'You have been marked as present for this event'
                            : 'Attendance will be marked during the event',
                        style: TextStyle(
                          color: _getStatusColor(hasAttended).withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QR Code Section - Added this section
          if (registration?.qrCode != null && registration!.qrCode.isNotEmpty)
            _buildQRCode(),
        ],
      ),
    );
  }

  Color _getStatusColor(bool hasAttended) {
    return hasAttended ? AppConstants.successColor : AppConstants.warningColor;
  }
}
