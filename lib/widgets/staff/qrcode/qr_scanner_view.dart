import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:megavent/utils/constants.dart';

class StaffQRScannerView extends StatelessWidget {
  final bool isProcessing;
  final double screenWidth;
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;

  const StaffQRScannerView({
    super.key,
    required this.isProcessing,
    required this.screenWidth,
    required this.controller,
    required this.onDetect,
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
            // MobileScanner without overlay parameter
            MobileScanner(controller: controller, onDetect: onDetect),
            // Overlay as a separate widget in the Stack
            _buildScannerOverlay(),
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

  Widget _buildScannerOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppConstants.primaryColor,
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 6,
          cutOutSize: screenWidth * 0.6,
        ),
      ),
    );
  }
}

// Custom overlay shape for the QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + borderRadius,
          rect.top,
        )
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _borderLength =
        borderLength > min(cutOutSize / 2, borderWidthSize)
            ? borderWidthSize
            : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint =
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    final boxPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    // Draw background
    canvas.saveLayer(rect, backgroundPaint);
    canvas.drawRect(rect, backgroundPaint);

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
          ..moveTo(
            cutOutRect.left - borderOffset,
            cutOutRect.top - borderOffset + _borderLength,
          )
          ..lineTo(
            cutOutRect.left - borderOffset,
            cutOutRect.top - borderOffset + borderRadius,
          )
          ..quadraticBezierTo(
            cutOutRect.left - borderOffset,
            cutOutRect.top - borderOffset,
            cutOutRect.left - borderOffset + borderRadius,
            cutOutRect.top - borderOffset,
          )
          ..lineTo(
            cutOutRect.left - borderOffset + _borderLength,
            cutOutRect.top - borderOffset,
          )
          // Top right
          ..moveTo(
            cutOutRect.right + borderOffset - _borderLength,
            cutOutRect.top - borderOffset,
          )
          ..lineTo(
            cutOutRect.right + borderOffset - borderRadius,
            cutOutRect.top - borderOffset,
          )
          ..quadraticBezierTo(
            cutOutRect.right + borderOffset,
            cutOutRect.top - borderOffset,
            cutOutRect.right + borderOffset,
            cutOutRect.top - borderOffset + borderRadius,
          )
          ..lineTo(
            cutOutRect.right + borderOffset,
            cutOutRect.top - borderOffset + _borderLength,
          )
          // Bottom right
          ..moveTo(
            cutOutRect.right + borderOffset,
            cutOutRect.bottom + borderOffset - _borderLength,
          )
          ..lineTo(
            cutOutRect.right + borderOffset,
            cutOutRect.bottom + borderOffset - borderRadius,
          )
          ..quadraticBezierTo(
            cutOutRect.right + borderOffset,
            cutOutRect.bottom + borderOffset,
            cutOutRect.right + borderOffset - borderRadius,
            cutOutRect.bottom + borderOffset,
          )
          ..lineTo(
            cutOutRect.right + borderOffset - _borderLength,
            cutOutRect.bottom + borderOffset,
          )
          // Bottom left
          ..moveTo(
            cutOutRect.left - borderOffset + _borderLength,
            cutOutRect.bottom + borderOffset,
          )
          ..lineTo(
            cutOutRect.left - borderOffset + borderRadius,
            cutOutRect.bottom + borderOffset,
          )
          ..quadraticBezierTo(
            cutOutRect.left - borderOffset,
            cutOutRect.bottom + borderOffset,
            cutOutRect.left - borderOffset,
            cutOutRect.bottom + borderOffset - borderRadius,
          )
          ..lineTo(
            cutOutRect.left - borderOffset,
            cutOutRect.bottom + borderOffset - _borderLength,
          );

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }

  double min(double x, double y) {
    return x < y ? x : y;
  }
}
