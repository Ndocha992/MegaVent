import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/info_row.dart';

class QRCodeSectionWidget extends StatelessWidget {
  final Attendee attendee;
  final Function(Attendee) onShowQRCode;

  const QRCodeSectionWidget({
    super.key,
    required this.attendee,
    required this.onShowQRCode,
  });

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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'QR Code Information',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: InfoRowWidget(label: 'QR Code', value: attendee.qrCode),
              ),
              IconButton(
                onPressed:
                    () => onShowQRCode(
                      attendee,
                    ), // This creates a callback function
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: AppConstants.primaryColor,
                ),
                tooltip: 'View QR Code',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
