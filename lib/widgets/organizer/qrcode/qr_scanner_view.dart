import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:megavent/utils/constants.dart';

class QRScannerView extends StatelessWidget {
  final GlobalKey qrKey;
  final bool isProcessing;
  final double screenWidth;
  final Function(QRViewController) onQRViewCreated;

  const QRScannerView({
    super.key,
    required this.qrKey,
    required this.isProcessing,
    required this.screenWidth,
    required this.onQRViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenWidth * 0.8, // Square aspect ratio based on screen width
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: AppConstants.primaryColor,
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 6,
                cutOutSize: screenWidth * 0.6, // Responsive cut out size
              ),
            ),
            if (isProcessing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing QR Code...',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}