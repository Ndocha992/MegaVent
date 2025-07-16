import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:megavent/utils/constants.dart';

class StaffQRScannerView extends StatefulWidget {
  final bool isProcessing;
  final double screenWidth;
  final Function(String) onDetect;
  final bool isFlashOn;
  final VoidCallback? onToggleFlash;

  const StaffQRScannerView({
    super.key,
    required this.isProcessing,
    required this.screenWidth,
    required this.onDetect,
    this.isFlashOn = false,
    this.onToggleFlash,
  });

  @override
  State<StaffQRScannerView> createState() => _StaffQRScannerViewState();
}

class _StaffQRScannerViewState extends State<StaffQRScannerView> {
  CameraController? _controller;
  BarcodeScanner? _barcodeScanner;
  bool _isDetecting = false;
  bool _isInitialized = false;
  List<CameraDescription> _cameras = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _barcodeScanner = BarcodeScanner();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        print('No cameras available');
        return;
      }

      // Find back camera or use first available
      CameraDescription camera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // Initialize camera controller with higher resolution for better QR detection
      _controller = CameraController(
        camera,
        ResolutionPreset.high, // Changed from medium to high
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      // Set flash mode if needed
      if (widget.isFlashOn) {
        await _controller!.setFlashMode(FlashMode.torch);
      }

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
        _startImageStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startImageStream() {
    if (_controller == null || !_controller!.value.isInitialized || _isDisposed) return;

    _controller!.startImageStream((CameraImage image) {
      if (!_isDetecting && mounted && !_isDisposed) {
        _isDetecting = true;
        _detectBarcodes(image);
      }
    });
  }

  Future<void> _detectBarcodes(CameraImage image) async {
    if (_barcodeScanner == null || _isDisposed) {
      _isDetecting = false;
      return;
    }

    try {
      // Convert CameraImage to InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      // Detect barcodes
      final List<Barcode> barcodes = await _barcodeScanner!.processImage(inputImage);

      // Process detected barcodes
      if (barcodes.isNotEmpty && mounted && !_isDisposed) {
        for (final barcode in barcodes) {
          if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
            print('QR Code detected: ${barcode.rawValue}');
            widget.onDetect(barcode.rawValue!);
            break; // Stop after first valid barcode
          }
        }
      }
    } catch (e) {
      print('Error detecting barcodes: $e');
    } finally {
      if (mounted && !_isDisposed) {
        _isDetecting = false;
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null || _isDisposed) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    // Fix rotation calculation
    InputImageRotation? rotation;
    if (camera.lensDirection == CameraLensDirection.front) {
      switch (sensorOrientation) {
        case 90:
          rotation = InputImageRotation.rotation270deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 0:
          rotation = InputImageRotation.rotation0deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }
    } else {
      switch (sensorOrientation) {
        case 90:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation270deg;
          break;
        case 0:
          rotation = InputImageRotation.rotation0deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      print('Unsupported image format: ${image.format.raw}');
      return null;
    }

    // Handle multiple planes properly
    if (image.planes.isEmpty) {
      print('No image planes available');
      return null;
    }

    // For YUV420 format, we need to handle multiple planes
    final plane = image.planes.first;
    final bytes = plane.bytes;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDisposed) return;

    try {
      if (widget.isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }

      if (widget.onToggleFlash != null) {
        widget.onToggleFlash!();
      }
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  void didUpdateWidget(StaffQRScannerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle flash state changes
    if (widget.isFlashOn != oldWidget.isFlashOn) {
      _updateFlashMode();
    }
  }

  Future<void> _updateFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized || _isDisposed) return;

    try {
      if (widget.isFlashOn) {
        await _controller!.setFlashMode(FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      print('Error updating flash mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scannerHeight = screenHeight * 0.6; // Make it responsive to screen height
    
    return Container(
      height: scannerHeight,
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
            // Camera Preview
            if (_isInitialized && _controller != null && !_isDisposed)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(_controller!),
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Custom Overlay with better sizing
            if (_isInitialized && !_isDisposed)
              CustomQROverlay(
                constraints: BoxConstraints(
                  maxWidth: widget.screenWidth,
                  maxHeight: scannerHeight,
                ),
                cutOutSize: widget.screenWidth * 0.7, // Increased from 0.6 to 0.7
                borderColor: AppConstants.primaryColor,
              ),

            // Flash Toggle Button
            if (widget.onToggleFlash != null && !_isDisposed)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ),
              ),

            // Processing Overlay
            if (widget.isProcessing && !_isDisposed)
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
                        SpinKitThreeBounce(
                          color: AppConstants.primaryColor,
                          size: 20.0,
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

            // Debug info (remove in production)
            if (_isInitialized && !_isDisposed)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ready to Scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.stopImageStream();
    _controller?.dispose();
    _barcodeScanner?.close();
    super.dispose();
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
    this.borderWidth = 4.0, // Reduced from 6.0
    this.borderLength = 30.0, // Reduced from 40.0
    this.borderRadius = 16.0, // Reduced from 20.0
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Semi-transparent overlay
    final overlayColor = Colors.black.withOpacity(0.6);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromLTWH(
      size.width / 2 - cutOutSize / 2,
      size.height / 2 - cutOutSize / 2,
      cutOutSize,
      cutOutSize,
    );

    // Draw background with cutout
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Clear the scanning area
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    // Draw corner borders with better visibility
    final path = Path()
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

    // Add scanning line animation (optional)
    final scanLinePaint = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        cutOutRect.left,
        cutOutRect.center.dy - 1,
        cutOutSize,
        2,
      ),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}