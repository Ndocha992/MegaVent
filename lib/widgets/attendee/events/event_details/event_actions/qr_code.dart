import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeQRCodeWidget extends StatelessWidget {
  final GlobalKey qrKey;
  final String data;

  const AttendeeQRCodeWidget({
    super.key,
    required this.qrKey,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Registration QR Code',
            style: AppConstants.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan to register for this event',
            style: AppConstants.bodySmallSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          RepaintBoundary(
            key: qrKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                embeddedImage: const AssetImage(
                  'assets/images/app_icon.png',
                ), // Optional: Add your app icon
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}