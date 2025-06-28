import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megavent/widgets/organizer/qrcode/manual_entry_dialog.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_action_buttons.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_header.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_instructions.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_result.dart';
import 'package:megavent/widgets/organizer/qrcode/qr_scanner_view.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String _scanResult = '';
  List<Event> _availableEvents = [];
  Event? _selectedEvent;
  late DatabaseService _databaseService;
  String currentRoute = '/organizer-scanqr';

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadAvailableEvents();
  }

  Future<void> _loadAvailableEvents() async {
    try {
      final events = await _databaseService.getEvents();
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

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
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
        title: 'QR Code Scanner',
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
                    _scanResult = ''; // Reset scan result when changing event
                  });
                },
              ),

              // QR Scanner View - Fixed height based on screen size
              QRScannerView(
                qrKey: qrKey,
                isProcessing: _isProcessing,
                screenWidth: screenWidth,
                onQRViewCreated: _onQRViewCreated,
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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && _selectedEvent != null) {
        _processQRCode(scanData.code ?? '');
      }
    });
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing || _selectedEvent == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Pause camera during processing
      await controller?.pauseCamera();

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
      await controller?.resumeCamera();
    }
  }

  Future<void> _checkInAttendee(String qrCode) async {
    try {
      // Parse QR code data (assuming it contains attendee ID or attendee information)
      // QR code can be in formats:
      // 1. Just attendee ID: "attendee123"
      // 2. Attendee ID with event: "attendee123:event456"
      // 3. Full format: "attendee123:event456:email@example.com"

      final qrParts = qrCode.split(':');
      if (qrParts.isEmpty) {
        throw Exception('Invalid QR code format');
      }

      final attendeeId = qrParts[0];

      // Get the attendee from the database for the selected event
      final attendee = await _databaseService.getAttendeeByIdAndEvent(
        attendeeId,
        _selectedEvent!.id,
      );

      if (attendee == null) {
        throw Exception('Attendee not found for this event');
      }

      // Check if attendee is already checked in
      if (attendee.hasAttended) {
        setState(() {
          _scanResult = '${attendee.fullName} is already checked in!';
        });
        return;
      }

      // Check in the attendee
      await _databaseService.checkInAttendee(attendeeId, _selectedEvent!.id);

      setState(() {
        _scanResult = '${attendee.fullName} checked in successfully!';
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Error: ${e.toString()}';
      });
      _showErrorSnackBar(e.toString());
    }
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
    setState(() {
      _scanResult = '';
      _isProcessing = false;
    });
    controller?.resumeCamera();
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
    controller?.dispose();
    super.dispose();
  }
}
