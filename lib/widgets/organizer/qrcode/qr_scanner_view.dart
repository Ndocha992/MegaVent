import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:megavent/utils/constants.dart';

class QRScannerView extends StatefulWidget {
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
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  bool _hasScanned = false;
  String _lastScannedCode = '';

  @override
  Widget build(BuildContext context) {
    final scannerHeight =
        widget.screenWidth * 1.2; // Made bigger for better visibility
    final scanWindowSize = widget.screenWidth * 0.8; // Larger scan window

    return Container(
      height: scannerHeight,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // AI Barcode Scanner with simplified configuration
            AiBarcodeScanner(
              onDetect: (BarcodeCapture capture) {
                if (capture.barcodes.isNotEmpty && !_hasScanned) {
                  final String? scannedValue = capture.barcodes.first.rawValue;
                  if (scannedValue != null &&
                      scannedValue.isNotEmpty &&
                      scannedValue.split('|').length == 5 &&
                      scannedValue != _lastScannedCode) {
                    setState(() {
                      _hasScanned = true;
                      _lastScannedCode = scannedValue;
                    });

                    // Add a small delay to show success feedback
                    Future.delayed(const Duration(milliseconds: 500), () {
                      widget.onDetect(scannedValue);

                      // Reset after processing
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _hasScanned = false;
                            _lastScannedCode = '';
                          });
                        }
                      });
                    });
                  }
                }
              },

              // Validator to ensure we only process valid QR codes
              validator: (value) {
                return value.barcodes.isNotEmpty &&
                    value.barcodes.first.rawValue != null &&
                    value.barcodes.first.rawValue!.isNotEmpty;
              },

              // Configure scan window for better detection
              scanWindow: Rect.fromCenter(
                center: Offset(widget.screenWidth / 2, scannerHeight / 2),
                width: scanWindowSize,
                height: scanWindowSize,
              ),

              // Simplified overlay without complex painting
              overlayBuilder: (
                context,
                constraints,
                controller,
                isPermissionGranted,
              ) {
                if (isPermissionGranted == false) {
                  return Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Camera permission required',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  );
                }

                return _buildSimpleOverlay(constraints, scanWindowSize);
              },

              // Handle disposal
              onDispose: () {
                debugPrint("QR Scanner disposed");
              },
            ),

            // Success feedback overlay
            if (_hasScanned && !widget.isProcessing)
              Container(
                color: Colors.green.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'QR Code Detected!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _lastScannedCode.length > 50
                                ? '${_lastScannedCode.substring(0, 50)}...'
                                : _lastScannedCode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Processing overlay
            if (widget.isProcessing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitThreeBounce(
                          color: AppConstants.primaryColor,
                          size: 24.0,
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

  Widget _buildSimpleOverlay(
    BoxConstraints constraints,
    double scanWindowSize,
  ) {
    return Stack(
      children: [
        // Semi-transparent overlay
        Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.black.withOpacity(0.6),
        ),

        // Clear scanning area with animated border
        Center(
          child: Container(
            width: scanWindowSize,
            height: scanWindowSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasScanned ? Colors.green : AppConstants.primaryColor,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner indicators with padding
                ...List.generate(4, (index) {
                  final isTop = index < 2;
                  final isLeft = index % 2 == 0;
                  const padding = 8.0;

                  return Positioned(
                    top: isTop ? padding : null,
                    bottom: isTop ? null : padding,
                    left: isLeft ? padding : null,
                    right: isLeft ? null : padding,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top:
                              isTop
                                  ? BorderSide(
                                    color:
                                        _hasScanned
                                            ? Colors.green
                                            : AppConstants.primaryColor,
                                    width: 3,
                                  )
                                  : BorderSide.none,
                          bottom:
                              !isTop
                                  ? BorderSide(
                                    color:
                                        _hasScanned
                                            ? Colors.green
                                            : AppConstants.primaryColor,
                                    width: 3,
                                  )
                                  : BorderSide.none,
                          left:
                              isLeft
                                  ? BorderSide(
                                    color:
                                        _hasScanned
                                            ? Colors.green
                                            : AppConstants.primaryColor,
                                    width: 3,
                                  )
                                  : BorderSide.none,
                          right:
                              !isLeft
                                  ? BorderSide(
                                    color:
                                        _hasScanned
                                            ? Colors.green
                                            : AppConstants.primaryColor,
                                    width: 3,
                                  )
                                  : BorderSide.none,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft:
                              (isTop && isLeft)
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                          topRight:
                              (isTop && !isLeft)
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                          bottomLeft:
                              (!isTop && isLeft)
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                          bottomRight:
                              (!isTop && !isLeft)
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }),

                // Scanning animation line
                if (!_hasScanned && !widget.isProcessing)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Positioned(
                        top: value * (scanWindowSize - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppConstants.primaryColor.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      if (mounted && !_hasScanned) {
                        setState(() {}); // Restart animation
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
