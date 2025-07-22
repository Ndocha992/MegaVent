import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_action_buttons.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_header.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_instructions.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_result.dart';
import 'package:megavent/widgets/staff/qrcode/qr_scanner_view.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
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
  bool _isDisposed = false;
  bool _scannerPaused = false;
  bool _canScan = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    await _checkAndRequestPermissions();
    await _loadStaffOrganizerId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        setState(() {
          _scannerPaused = true;
        });
        break;
      case AppLifecycleState.resumed:
        setState(() {
          _scannerPaused = false;
        });
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _loadStaffOrganizerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final staffDoc =
            await FirebaseFirestore.instance
                .collection('staff')
                .doc(user.uid)
                .get();

        if (staffDoc.exists && mounted) {
          setState(() {
            _organizerId = staffDoc.data()?['organizerId'];
          });
          await _loadAvailableEvents();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load staff data: ${e.toString()}');
      }
    }
  }

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

      if (mounted) {
        setState(() {
          _availableEvents = activeEvents;
          if (activeEvents.isNotEmpty) {
            _selectedEvent = activeEvents.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load events: ${e.toString()}');
      }
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    if (mounted) {
      setState(() {
        _isCheckingPermissions = true;
      });
    }

    try {
      PermissionStatus cameraStatus = await Permission.camera.status;

      if (cameraStatus.isDenied) {
        cameraStatus = await Permission.camera.request();
      }

      if (mounted) {
        setState(() {
          _isCameraPermissionGranted = cameraStatus.isGranted;
          _isCheckingPermissions = false;
        });

        if (cameraStatus.isPermanentlyDenied) {
          _showPermissionDialog();
        } else if (!cameraStatus.isGranted) {
          _showErrorSnackBar('Camera permission is required to scan QR codes');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraPermissionGranted = false;
          _isCheckingPermissions = false;
        });
        _showErrorSnackBar('Error checking camera permission: ${e.toString()}');
      }
    }
  }

  void _showPermissionDialog() {
    if (!mounted) return;

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
              onPressed: () => Navigator.of(context).pop(),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight - statusBarHeight;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'QR Scanner',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: StaffSidebar(currentRoute: currentRoute),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    _canScan = true;
                  });
                },
              ),

              // Scanner Section - Fixed height to 70% of available screen height
              SizedBox(
                height: availableHeight * 0.7,
                child: _buildScannerSection(screenWidth),
              ),

              // Instructions and Result Section
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_scanResult.isEmpty) ...[
                      StaffQRScannerInstructions(selectedEvent: _selectedEvent),
                    ] else ...[
                      StaffQRScannerResult(scanResult: _scanResult),
                    ],

                    const SizedBox(height: 20),

                    // Action Buttons
                    StaffQRScannerActionButtons(
                      selectedEvent: _selectedEvent,
                      onResetScanner: _resetScanner,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerSection(double screenWidth) {
    if (_isCheckingPermissions) {
      return _buildPermissionCheckingWidget(screenWidth);
    } else if (!_isCameraPermissionGranted) {
      return _buildPermissionDeniedWidget(screenWidth);
    } else {
      return StaffQRScannerView(
        isProcessing: _isProcessing,
        screenWidth: screenWidth,
        onDetect: _onDetect,
        isFlashOn: _isFlashOn,
        onToggleFlash: _toggleFlash,
      );
    }
  }

  Widget _buildPermissionCheckingWidget(double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
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
    );
  }

  Widget _buildPermissionDeniedWidget(double screenWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey[600]),
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
              style: AppConstants.bodyMedium.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _checkAndRequestPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _onDetect(String qrCode) {
    if (!_isProcessing &&
        _selectedEvent != null &&
        !_isDisposed &&
        !_scannerPaused &&
        _canScan) {
      if (qrCode.isNotEmpty) {
        setState(() => _canScan = false);
        _processQRCode(qrCode);
      }
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing || _selectedEvent == null || _isDisposed) return;

    setState(() => _isProcessing = true);

    try {
      HapticFeedback.mediumImpact();

      // Process as event QR code format
      final parts = qrCode.split('|');
      if (parts.length == 5) {
        await _checkInAttendee(qrCode);
      } else {
        setState(() => _scanResult = 'QR Code Content: $qrCode');
        _showSuccessSnackBar('QR Code scanned successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanResult = 'Error: ${e.toString()}');
        _showErrorSnackBar('Failed to process QR code: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _canScan = true);
        });
      }
    }
  }

  Future<void> _checkInAttendee(String qrCode) async {
    if (_selectedEvent == null || _organizerId == null || _isDisposed) {
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final qrParts = qrCode.split('|');
      if (qrParts.length < 5) throw Exception('Invalid QR format');

      final attendeeId = qrParts[0];
      final eventId = qrParts[1];
      final timestamp = qrParts[2];
      final organizerId = qrParts[3];
      final hash = qrParts[4];

      // Verify event matches selected event
      if (eventId != _selectedEvent!.id) {
        throw Exception(
          'QR is for different event: ${_selectedEvent!.id} vs $eventId',
        );
      }

      // Verify QR integrity
      final rawData = '$attendeeId|$eventId|$timestamp|$organizerId';
      final bytes = utf8.encode(rawData);
      final digest = sha256.convert(bytes);
      final expectedHash = digest.toString().substring(0, 16);

      if (hash != expectedHash) throw Exception('Invalid QR: Hash mismatch');

      // Verify organizer matches
      if (organizerId != _organizerId) {
        throw Exception(
          'Attendee not registered for event. Organizer mismatch: $_organizerId vs $organizerId',
        );
      }

      // Get attendee data
      final attendeeData = await _databaseService.getAttendeeByIdAndEvent(
        attendeeId,
        eventId,
      );
      if (attendeeData == null) throw Exception('Attendee not found');

      // Check if already attended
      if (attendeeData['attended'] == true) {
        final name = attendeeData['fullName'] ?? 'Attendee';
        setState(() => _scanResult = '$name already checked in!');
        return;
      }

      await _databaseService.markAttendanceByQRCode(
        qrCode,
        FirebaseAuth.instance.currentUser!.uid,
      );

      // Show success
      final name = attendeeData['fullName'] ?? 'Attendee';
      setState(() => _scanResult = '$name checked in successfully!');
      _showSuccessSnackBar('Attendee checked in successfully!');
    } catch (e) {
      setState(() => _scanResult = 'Error: ${e.toString()}');
      _showErrorSnackBar(e.toString());
    }
  }

  void _toggleFlash() {
    if (_isDisposed) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _resetScanner() {
    if (_isDisposed) return;

    setState(() {
      _scanResult = '';
      _isProcessing = false;
      _scannerPaused = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
