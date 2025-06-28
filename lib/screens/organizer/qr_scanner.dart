import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  String _scanResult = '';
  List<Event> _availableEvents = [];
  Event? _selectedEvent;
  late DatabaseService _databaseService;

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Selection Dropdown
          if (_availableEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Event: ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Expanded(
                    child: DropdownButton<Event>(
                      value: _selectedEvent,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      underline: Container(),
                      isExpanded: true,
                      items:
                          _availableEvents.map((event) {
                            return DropdownMenuItem<Event>(
                              value: event,
                              child: Text(
                                event.name,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (Event? newValue) {
                        setState(() {
                          _selectedEvent = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          // QR Scanner View
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: AppConstants.primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Instructions and Result Section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_scanResult.isEmpty) ...[
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white70,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedEvent != null
                          ? 'Scanning for: ${_selectedEvent!.name}'
                          : 'Please select an event first',
                      style: TextStyle(
                        color:
                            _selectedEvent != null
                                ? AppConstants.primaryColor
                                : Colors.orange,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _scanResult.contains('Error')
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _scanResult.contains('Error')
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _scanResult.contains('Error')
                                ? Icons.error
                                : Icons.check_circle,
                            color:
                                _scanResult.contains('Error')
                                    ? Colors.red
                                    : Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _scanResult.contains('Error')
                                ? 'Scan Failed'
                                : 'Scan Successful!',
                            style: TextStyle(
                              color:
                                  _scanResult.contains('Error')
                                      ? Colors.red
                                      : Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _scanResult,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _resetScanner,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _selectedEvent != null ? _manualEntry : null,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Manual Entry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      await Future.delayed(const Duration(seconds: 2));
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
        final TextEditingController attendeeIdController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Manual Check-in'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Event: ${_selectedEvent?.name ?? 'None selected'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: attendeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Attendee ID *',
                    hintText: 'Enter attendee ID from QR code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter the attendee ID to manually check them in',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final attendeeId = attendeeIdController.text.trim();
                if (attendeeId.isNotEmpty) {
                  Navigator.of(context).pop();
                  _processQRCode(attendeeId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
