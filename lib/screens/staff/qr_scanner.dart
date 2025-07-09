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
  late MobileScannerController _scannerController;
  bool _isProcessing = false;
  String _scanResult = '';
  List<Event> _availableEvents = [];
  Event? _selectedEvent;
  late DatabaseService _databaseService;
  String currentRoute = '/staff-scanqr';
  bool _isFlashOn = false;
  bool _isCameraPermissionGranted = false;
  bool _isCheckingPermissions = true;
  String? _organizerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _checkAndRequestPermissions();
    _loadStaffOrganizerId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _scannerController.stop();
        break;
      case AppLifecycleState.resumed:
        // Check permissions again when app resumes
        _checkAndRequestPermissions();
        if (_isCameraPermissionGranted) {
          _scannerController.start();
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
          await _loadAvailableEvents(); // Then load events
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
    });

    try {
      // Check current camera permission status
      PermissionStatus cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied) {
        // Request camera permission
        cameraStatus = await Permission.camera.request();
      }

      if (cameraStatus.isGranted) {
        setState(() {
          _isCameraPermissionGranted = true;
        });
        _initializeScanner();
      } else if (cameraStatus.isPermanentlyDenied) {
        setState(() {
          _isCameraPermissionGranted = false;
        });
        _showPermissionDialog();
      } else {
        setState(() {
          _isCameraPermissionGranted = false;
        });
        _showErrorSnackBar('Camera permission is required to scan QR codes');
      }
    } catch (e) {
      setState(() {
        _isCameraPermissionGranted = false;
      });
      _showErrorSnackBar('Error checking camera permission: ${e.toString()}');
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

  void _initializeScanner() {
    if (!_isCameraPermissionGranted) return;

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Start the scanner
    _scannerController.start().catchError((error) {
      if (mounted) {
        setState(() {
          _isCameraPermissionGranted = false;
        });
        _showErrorSnackBar('Failed to start camera: ${error.toString()}');
      }
    });
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
            onPressed: _isCameraPermissionGranted ? _toggleFlash : null,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? AppConstants.warningColor : Colors.white,
            ),
            tooltip: 'Toggle Flash',
          ),
          // Camera switch button
          IconButton(
            onPressed: _isCameraPermissionGranted ? _switchCamera : null,
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
                    _scanResult = ''; // Reset scan result when changing event
                  });
                },
              ),

              // Permission checking state
              if (_isCheckingPermissions)
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
                          'Checking Camera Permission...',
                          style: AppConstants.headlineSmall.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Camera permission not granted
              else if (!_isCameraPermissionGranted)
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
                          child: const Text('Grant Permission'),
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
              else
                // QR Scanner View - Fixed height based on screen size
                StaffQRScannerView(
                  isProcessing: _isProcessing,
                  screenWidth: screenWidth,
                  controller: _scannerController,
                  onDetect: _onDetect,
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

                    const SizedBox(height: 16), // Bottom padding
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
    if (barcodes.isNotEmpty && !_isProcessing && _selectedEvent != null) {
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
      await _scannerController.stop();

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
      if (mounted && _isCameraPermissionGranted) {
        await _scannerController.start();
      }
    }
  }

  Future<void> _checkInAttendee(String qrCode) async {
    if (_isProcessing || _selectedEvent == null || _organizerId == null) return;

    setState(() => _isProcessing = true);

    try {
      await _scannerController.stop();
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
      if (mounted && _isCameraPermissionGranted)
        await _scannerController.start();
    }
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _scannerController.toggleTorch();
  }

  void _switchCamera() {
    _scannerController.switchCamera();
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
    if (_isCameraPermissionGranted) {
      _scannerController.start();
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
    if (_isCameraPermissionGranted) {
      _scannerController.dispose();
    }
    super.dispose();
  }
}
