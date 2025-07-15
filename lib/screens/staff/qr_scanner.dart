import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megavent/widgets/staff/qrcode/manual_entry_dialog.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_action_buttons.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_header.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_instructions.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_result.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_view.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class StaffQRScanner extends StatefulWidget {
  const StaffQRScanner({super.key});

  @override
  State<StaffQRScanner> createState() => _StaffQRScannerState();
}

class _StaffQRScannerState extends State<StaffQRScanner>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  String _scanResult = '';
  List<Event> _availableEvents = [];
  Event? _selectedEvent;
  late DatabaseService _databaseService;
  String currentRoute = '/staff-scanqr';
  bool _isFlashOn = false;
  bool _isCameraPermissionGranted = false;
  bool _isCheckingPermissions = true;
  bool _isInitializingCamera = false;
  bool _isScannerReady = false;
  String? _organizerId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadStaffOrganizerId();
    await _checkAndRequestPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _stopScanner();
        break;
      case AppLifecycleState.resumed:
        if (_isCameraPermissionGranted && !_isInitializingCamera) {
          _reinitializeScanner();
        }
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  // Load organizer ID
  Future<void> _loadStaffOrganizerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final staffDoc =
            await FirebaseFirestore.instance
                .collection('staff')
                .doc(user.uid)
                .get();

        if (staffDoc.exists) {
          setState(() {
            _organizerId = staffDoc.data()?['organizerId'];
          });
          await _loadAvailableEvents();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load staff data: ${e.toString()}');
    }
  }

  // Update event loading to use organizer ID
  Future<void> _loadAvailableEvents() async {
    if (_organizerId == null) return;

    try {
      final events = await _databaseService.getEventsForOrganizer(
        _organizerId!,
      );
      final activeEvents =
          events
              .where(
                (event) =>
                    event.startDate.isAfter(DateTime.now()) ||
                    (event.startDate.isBefore(DateTime.now()) &&
                        event.endDate.isAfter(DateTime.now())),
              )
              .toList();

      setState(() {
        _availableEvents = activeEvents;
        if (activeEvents.isNotEmpty) {
          _selectedEvent = activeEvents.first;
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load events: ${e.toString()}');
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
      _errorMessage = null;
    });

    try {
      // Check current camera permission status
      PermissionStatus cameraStatus = await Permission.camera.status;

      print('Initial camera permission status: $cameraStatus');

      // If permission is denied, request it
      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
        print('After request camera permission status: $cameraStatus');
      }

      if (cameraStatus.isGranted) {
        setState(() {
          _isCameraPermissionGranted = true;
          _errorMessage = null;
        });
        // Add longer delay to ensure permission is fully processed on real devices
        await Future.delayed(const Duration(milliseconds: 1000));
        await _initializeScanner();
      } else if (cameraStatus.isPermanentlyDenied) {
        setState(() {
          _isCameraPermissionGranted = false;
          _errorMessage =
              'Camera permission is permanently denied. Please enable it in app settings.';
        });
        _showPermissionDialog();
      } else {
        setState(() {
          _isCameraPermissionGranted = false;
          _errorMessage = 'Camera permission is required to scan QR codes.';
        });
      }
    } catch (e) {
      print('Error checking camera permission: $e');
      setState(() {
        _isCameraPermissionGranted = false;
        _errorMessage = 'Error checking camera permission: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isCheckingPermissions = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text(
            'This app needs camera access to scan QR codes. Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeScanner() async {
    if (!_isCameraPermissionGranted || _isInitializingCamera) return;

    setState(() {
      _isInitializingCamera = true;
      _isScannerReady = false;
      _errorMessage = null;
    });

    try {
      // Dispose existing controller if any
      await _disposeScanner();

      // Wait a bit before creating new controller
      await Future.delayed(const Duration(milliseconds: 500));

      // Create new controller with more specific configuration for real devices
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
        // Add formats for better compatibility
        formats: [BarcodeFormat.qrCode],
        // Add detection timeout
        detectionTimeoutMs: 2500,
        // Use normal scanning mode for better compatibility
        autoStart: false,
      );

      print('Scanner controller created, waiting for initialization...');

      // Wait for controller to be ready before starting
      await Future.delayed(const Duration(milliseconds: 1000));

      // Start the scanner with proper error handling
      await _scannerController!.start();

      print('Scanner started successfully');

      // Wait a bit more to ensure scanner is fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isInitializingCamera = false;
        _isScannerReady = true;
      });
    } catch (e) {
      print('Failed to initialize scanner: $e');
      setState(() {
        _isInitializingCamera = false;
        _isScannerReady = false;
        _errorMessage = 'Failed to start camera: ${e.toString()}';
      });

      // Dispose failed controller
      await _disposeScanner();

      // Try to reinitialize after a longer delay for real devices
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isCameraPermissionGranted) {
          _reinitializeScanner();
        }
      });
    }
  }

  Future<void> _reinitializeScanner() async {
    if (_isInitializingCamera) return;

    print('Reinitializing scanner...');
    await _disposeScanner();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _initializeScanner();
  }

  Future<void> _disposeScanner() async {
    if (_scannerController != null) {
      try {
        await _scannerController!.stop();
        await _scannerController!.dispose();
        _scannerController = null;
        setState(() {
          _isScannerReady = false;
        });
      } catch (e) {
        print('Error disposing scanner: $e');
      }
    }
  }

  Future<void> _stopScanner() async {
    if (_scannerController != null && _isScannerReady) {
      try {
        await _scannerController!.stop();
        setState(() {
          _isScannerReady = false;
        });
      } catch (e) {
        print('Error stopping scanner: $e');
      }
    }
  }

  Future<void> _startScanner() async {
    if (_scannerController != null &&
        !_isScannerReady &&
        !_isInitializingCamera) {
      try {
        await _scannerController!.start();
        setState(() {
          _isScannerReady = true;
        });
      } catch (e) {
        print('Error starting scanner: $e');
        _reinitializeScanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableHeight =
        screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        actions: [
          // Flash toggle button
          IconButton(
            onPressed:
                _isCameraPermissionGranted &&
                        _scannerController != null &&
                        _isScannerReady
                    ? _toggleFlash
                    : null,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? AppConstants.warningColor : Colors.white,
            ),
            tooltip: 'Toggle Flash',
          ),
          // Camera switch button
          IconButton(
            onPressed:
                _isCameraPermissionGranted &&
                        _scannerController != null &&
                        _isScannerReady
                    ? _switchCamera
                    : null,
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      drawer: StaffSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: availableHeight),
          child: Column(
            children: [
              // Header Section with Event Selection
              StaffQRScannerHeader(
                availableEvents: _availableEvents,
                selectedEvent: _selectedEvent,
                onEventChanged: (Event? newEvent) {
                  setState(() {
                    _selectedEvent = newEvent;
                    _scanResult = '';
                  });
                },
              ),

              // Permission checking state
              if (_isCheckingPermissions || _isInitializingCamera)
                Container(
                  height: screenWidth * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _isCheckingPermissions
                              ? 'Checking Camera Permission...'
                              : 'Initializing Camera...',
                          style: AppConstants.headlineSmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_isInitializingCamera) ...[
                          const SizedBox(height: 8),
                          Text(
                            'This may take a moment on real devices',
                            style: AppConstants.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              // Camera permission not granted or error
              else if (!_isCameraPermissionGranted || _errorMessage != null)
                Container(
                  height: screenWidth * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Camera Permission Required',
                          style: AppConstants.headlineSmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ??
                              'Please enable camera access to scan QR codes',
                          style: AppConstants.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _checkAndRequestPermissions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_scannerController != null && _isScannerReady)
                // QR Scanner View - Only show if controller exists and is ready
                StaffQRScannerView(
                  isProcessing: _isProcessing,
                  screenWidth: screenWidth,
                  controller: _scannerController!,
                  onDetect: _onDetect,
                )
              else
                Container(
                  height: screenWidth * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Starting Camera...',
                          style: AppConstants.headlineSmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait while we initialize the camera',
                          style: AppConstants.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _reinitializeScanner,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Instructions and Result Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (_scanResult.isEmpty) ...[
                      StaffQRScannerInstructions(selectedEvent: _selectedEvent),
                    ] else ...[
                      StaffQRScannerResult(scanResult: _scanResult),
                    ],
                    const SizedBox(height: 16),

                    // Action Buttons
                    StaffQRScannerActionButtons(
                      selectedEvent: _selectedEvent,
                      onResetScanner: _resetScanner,
                      onManualEntry: _manualEntry,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty &&
        !_isProcessing &&
        _selectedEvent != null &&
        _isScannerReady) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _processQRCode(code);
      }
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing || _selectedEvent == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Pause camera during processing
      await _stopScanner();

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Process the QR code data
      await _checkInAttendee(qrCode);
    } catch (e) {
      _showErrorSnackBar('Failed to process QR code: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });

      // Resume camera after a short delay
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _isCameraPermissionGranted && _scannerController != null) {
        await _startScanner();
      }
    }
  }

  Future<void> _checkInAttendee(String qrCode) async {
    if (_isProcessing || _selectedEvent == null || _organizerId == null) return;

    setState(() => _isProcessing = true);

    try {
      await _stopScanner();
      HapticFeedback.mediumImpact();

      // Parse QR code using new format
      final qrParts = qrCode.split('|');
      if (qrParts.length < 5) throw Exception('Invalid QR code format');

      final attendeeId = qrParts[0];
      final eventId = qrParts[1];
      final timestamp = qrParts[2];
      final organizerId = qrParts[3];
      final hash = qrParts[4];

      // Verify QR code integrity
      final rawData = '$attendeeId|$eventId|$timestamp|$organizerId';
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);
      final expectedHash = digest.toString().substring(0, 16);

      if (hash != expectedHash) {
        throw Exception('Invalid or tampered QR code');
      }

      // Verify event belongs to organizer
      if (organizerId != _organizerId) {
        throw Exception('Attendee not registered for your organizer\'s event');
      }

      // Get attendee data
      final attendeeData = await _databaseService.getAttendeeByIdAndEvent(
        attendeeId,
        eventId,
      );

      if (attendeeData == null) throw Exception('Attendee not found');

      // Check if already attended
      if (attendeeData['hasAttended'] == true) {
        setState(
          () => _scanResult = '${attendeeData['fullName']} already checked in!',
        );
        return;
      }

      // Check in attendee
      await _databaseService.checkInAttendee(
        attendeeId,
        eventId,
        FirebaseAuth.instance.currentUser!.uid,
      );

      setState(
        () =>
            _scanResult =
                '${attendeeData['fullName']} checked in successfully!',
      );
    } catch (e) {
      setState(() => _scanResult = 'Error: ${e.toString()}');
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isProcessing = false);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _isCameraPermissionGranted && _scannerController != null) {
        await _startScanner();
      }
    }
  }

  void _toggleFlash() {
    if (_scannerController != null && _isScannerReady) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
      _scannerController!.toggleTorch();
    }
  }

  void _switchCamera() {
    if (_scannerController != null && _isScannerReady) {
      _scannerController!.switchCamera();
    }
  }

  void _manualEntry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StaffManualEntryDialog(
          selectedEvent: _selectedEvent,
          onCheckIn: (String attendeeId, String eventId) {
            _processManualEntry(attendeeId, eventId);
          },
        );
      },
    );
  }

  Future<void> _processManualEntry(String attendeeId, String eventId) async {
    if (_isProcessing || _organizerId == null) return;

    setState(() => _isProcessing = true);

    try {
      // Get attendee data
      final attendeeData = await _databaseService.getAttendeeByIdAndEvent(
        attendeeId,
        eventId,
      );

      if (attendeeData == null) throw Exception('Attendee not found');

      // Verify event belongs to organizer
      if (attendeeData['organizerId'] != _organizerId) {
        throw Exception('Attendee not registered for your organizer\'s event');
      }

      // Check if already attended
      if (attendeeData['hasAttended'] == true) {
        setState(
          () => _scanResult = '${attendeeData['fullName']} already checked in!',
        );
        return;
      }

      // Check in attendee
      await _databaseService.checkInAttendee(
        attendeeId,
        eventId,
        FirebaseAuth.instance.currentUser!.uid,
      );

      setState(
        () =>
            _scanResult =
                '${attendeeData['fullName']} checked in successfully!',
      );
    } catch (e) {
      setState(() => _scanResult = 'Error: ${e.toString()}');
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _resetScanner() {
    setState(() {
      _scanResult = '';
      _isProcessing = false;
    });
    if (_isCameraPermissionGranted && _scannerController != null) {
      _startScanner();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeScanner();
    super.dispose();
  }
}
