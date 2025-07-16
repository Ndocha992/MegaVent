import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megavent/widgets/organizer/qrcode/manual_entry_dialog.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_action_buttons.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_header.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_instructions.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_result.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_view.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isProcessing = false;
  String _scanResult = '';
  List<Event> _availableEvents = [];
  Event? _selectedEvent;
  late DatabaseService _databaseService;
  String currentRoute = '/organizer-scanqr';
  bool _isFlashOn = false;
  bool _isCameraPermissionGranted = false;
  bool _isCheckingPermissions = true;
  String? _organizerId;
  bool _isDisposed = false;
  bool _scannerPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _checkAndRequestPermissions();
    _loadOrganizerData();
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
        _checkAndRequestPermissions();
        if (_isCameraPermissionGranted && !_isDisposed) {
          setState(() {
            _scannerPaused = false;
          });
        }
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _loadOrganizerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _organizerId = user.uid;
        });
        await _loadAvailableEvents();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load organizer data: ${e.toString()}');
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
        if (cameraStatus.isGranted) {
          setState(() {
            _isCameraPermissionGranted = true;
          });
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraPermissionGranted = false;
        });
        _showErrorSnackBar('Error checking camera permission: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermissions = false;
        });
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
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: availableHeight),
          child: Column(
            children: [
              // Header Section with Event Selection
              QRScannerHeader(
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
              if (_isCheckingPermissions)
                _buildPermissionCheckingWidget(screenWidth)
              // Camera permission not granted
              else if (!_isCameraPermissionGranted)
                _buildPermissionDeniedWidget(screenWidth)
              else
                // QR Scanner View
                QRScannerView(
                  isProcessing: _isProcessing,
                  screenWidth: screenWidth,
                  onDetect: _onDetect,
                  isFlashOn: _isFlashOn,
                  onToggleFlash: _toggleFlash,
                ),

              const SizedBox(height: 16),

              // Instructions and Result Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (_scanResult.isEmpty) ...[
                      QRScannerInstructions(selectedEvent: _selectedEvent),
                    ] else ...[
                      QRScannerResult(scanResult: _scanResult),
                    ],
                    const SizedBox(height: 16),

                    // Action Buttons
                    QRScannerActionButtons(
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

  Widget _buildPermissionCheckingWidget(double screenWidth) {
    return Container(
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
    );
  }

  Widget _buildPermissionDeniedWidget(double screenWidth) {
    return Container(
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
    );
  }

  void _onDetect(String qrCode) {
    if (!_isProcessing &&
        _selectedEvent != null &&
        !_isDisposed &&
        !_scannerPaused) {
      if (qrCode.isNotEmpty) {
        _processQRCode(qrCode);
      }
    }
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing || _selectedEvent == null || _isDisposed) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _scannerPaused = true;
      });
    }

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Process the QR code data
      await _checkInAttendee(qrCode);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to process QR code: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      // Resume scanner after a short delay
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _isCameraPermissionGranted && !_isDisposed) {
        setState(() {
          _scannerPaused = false;
        });
      }
    }
  }

  Future<void> _checkInAttendee(String qrCode) async {
    if (_isProcessing ||
        _selectedEvent == null ||
        _organizerId == null ||
        _isDisposed) {
      return;
    }

    try {
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
        throw Exception('Attendee not registered for your event');
      }

      // Get attendee data
      final attendeeData = await _databaseService.getAttendeeByIdAndEvent(
        attendeeId,
        eventId,
      );

      if (attendeeData == null) throw Exception('Attendee not found');

      // Check if already attended
      if (attendeeData['hasAttended'] == true) {
        if (mounted) {
          setState(
            () =>
                _scanResult = '${attendeeData['fullName']} already checked in!',
          );
        }
        return;
      }

      // Check in attendee
      await _databaseService.checkInAttendee(
        attendeeId,
        eventId,
        FirebaseAuth.instance.currentUser!.uid,
      );

      if (mounted) {
        setState(
          () =>
              _scanResult =
                  '${attendeeData['fullName']} checked in successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanResult = 'Error: ${e.toString()}');
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _toggleFlash() {
    if (_isDisposed) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _manualEntry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ManualEntryDialog(
          selectedEvent: _selectedEvent,
          onCheckIn: (String attendeeId) {
            _processQRCode(attendeeId);
          },
        );
      },
    );
  }

  void _resetScanner() {
    if (_isDisposed) return;

    setState(() {
      _scanResult = '';
      _isProcessing = false;
      _scannerPaused = false;
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

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
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
