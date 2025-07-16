import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:megavent/utils/constants.dart';

class QRScannerView extends StatelessWidget {
  final bool isProcessing;
  final double screenWidth;
  final Function(String) onDetect;
  final bool isFlashOn;
  final VoidCallback? onToggleFlash;

  const QRScannerView({
    super.key,
    required this.isProcessing,
    required this.screenWidth,
    required this.onDetect,
    this.isFlashOn = false,
    this.onToggleFlash,
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
            // AI Barcode Scanner View
            AiBarcodeScanner(
              onDetect: (BarcodeCapture capture) {
                final String? scannedValue =
                    capture.barcodes.isNotEmpty
                        ? capture.barcodes.first.rawValue
                        : null;
                if (scannedValue != null && scannedValue.isNotEmpty) {
                  onDetect(scannedValue);
                }
              },
              validator: (value) {
                return value.barcodes.isNotEmpty;
              },
              overlayBuilder: (
                context,
                constraints,
                controller,
                isPermissionGranted,
              ) {
                return CustomQROverlay(
                  constraints: constraints,
                  cutOutSize: screenWidth * 0.6,
                  borderColor: AppConstants.primaryColor,
                );
              },
              onDispose: () {
                // Handle disposal if needed
              },
            ),

            // Processing overlay
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
                        Center(
                          child: SpinKitThreeBounce(
                            color: AppConstants.primaryColor,
                            size: 20.0,
                          ),
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

// Custom overlay for the QR scanner
class CustomQROverlay extends StatelessWidget {
  final BoxConstraints constraints;
  final double cutOutSize;
  final Color borderColor;

  const CustomQROverlay({
    super.key,
    required this.constraints,
    required this.cutOutSize,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: QROverlayPainter(
        cutOutSize: cutOutSize,
        borderColor: borderColor,
      ),
      child: Container(),
    );
  }
}

class QROverlayPainter extends CustomPainter {
  final double cutOutSize;
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;

  QROverlayPainter({
    required this.cutOutSize,
    required this.borderColor,
    this.borderWidth = 6.0,
    this.borderLength = 40.0,
    this.borderRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayColor = const Color.fromRGBO(0, 0, 0, 80);
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round;

    final backgroundPaint =
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill;

    final boxPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      size.width / 2 - cutOutSize / 2,
      size.height / 2 - cutOutSize / 2,
      cutOutSize,
      cutOutSize,
    );

    // Draw background
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw cutout
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      boxPaint,
    );
    canvas.restore();

    // Draw corner borders
    final path =
        Path()
          // Top left
          ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
          ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
          ..quadraticBezierTo(
            cutOutRect.left,
            cutOutRect.top,
            cutOutRect.left + borderRadius,
            cutOutRect.top,
          )
          ..lineTo(cutOutRect.left + borderLength, cutOutRect.top)
          // Top right
          ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
          ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
          ..quadraticBezierTo(
            cutOutRect.right,
            cutOutRect.top,
            cutOutRect.right,
            cutOutRect.top + borderRadius,
          )
          ..lineTo(cutOutRect.right, cutOutRect.top + borderLength)
          // Bottom right
          ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
          ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
          ..quadraticBezierTo(
            cutOutRect.right,
            cutOutRect.bottom,
            cutOutRect.right - borderRadius,
            cutOutRect.bottom,
          )
          ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom)
          // Bottom left
          ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom)
          ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
          ..quadraticBezierTo(
            cutOutRect.left,
            cutOutRect.bottom,
            cutOutRect.left,
            cutOutRect.bottom - borderRadius,
          )
          ..lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
