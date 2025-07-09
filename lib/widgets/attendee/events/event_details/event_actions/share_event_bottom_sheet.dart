import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/qr_code.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/share_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:megavent/utils/constants.dart';
import 'bottom_sheet_header.dart';
import 'package:intl/intl.dart';

class AttendeeShareEventBottomSheet extends StatefulWidget {
  final Event event;

  const AttendeeShareEventBottomSheet({super.key, required this.event});

  @override
  State<AttendeeShareEventBottomSheet> createState() => _AttendeeShareEventBottomSheetState();
}

class _AttendeeShareEventBottomSheetState extends State<AttendeeShareEventBottomSheet> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSharing = false;
  String? _registrationLink;

  @override
  void initState() {
    super.initState();
    _generateRegistrationLink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          AttendeeBottomSheetHeader(
            icon: Icons.share,
            title: 'Share Event',
            subtitle: 'Share registration QR code',
            iconColor: AppConstants.primaryColor,
            onClose: () => Navigator.pop(context),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildEventInfoCard(),
                  const SizedBox(height: 24),
                  QRCodeWidget(
                    qrKey: _qrKey,
                    data: _registrationLink ?? 'Loading...',
                  ),
                  const SizedBox(height: 24),
                  _buildShareOptions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatEventDate(),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${widget.event.startTime} - ${widget.event.endTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${widget.event.registeredCount}/${widget.event.capacity} registered',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions() {
    return Column(
      children: [
        const Text(
          'Share Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Share Buttons
        Row(
          children: [
            Expanded(
              child: ShareButtonWidget(
                icon: Icons.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                isLoading: _isSharing,
                onTap: () => _shareToWhatsApp(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShareButtonWidget(
                icon: Icons.copy,
                label: 'Copy Link',
                color: AppConstants.primaryColor,
                isLoading: _isSharing,
                onTap: () => _copyLink(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ShareButtonWidget(
                icon: Icons.download,
                label: 'Save QR',
                color: AppConstants.successColor,
                isLoading: _isSharing,
                onTap: () => _saveQRCode(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ShareButtonWidget(
                icon: Icons.share,
                label: 'More',
                color: Colors.grey[600]!,
                isLoading: _isSharing,
                onTap: () => _shareMore(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _generateRegistrationLink() {
    // Generate deep link that opens app or download page
    final String appDeepLink = 'megavent://register?eventId=${widget.event.id}&autoRegister=true';
    
    setState(() {
      _registrationLink = appDeepLink;
    });
  }

  String _formatEventDate() {
    final startDate = widget.event.startDate;
    final endDate = widget.event.endDate;

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // Same day event
      return DateFormat('EEEE, MMMM d, yyyy').format(startDate);
    } else {
      // Multi-day event
      return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    }
  }

  String _getShareText() {
    return '''🎉 Join me at ${widget.event.name}!

📅 Date: ${_formatEventDate()}
⏰ Time: ${widget.event.startTime} - ${widget.event.endTime}
📍 Location: ${widget.event.location}
👥 Capacity: ${widget.event.capacity} people

🔹 Scan the QR code to automatically register (Attendees only)
🔹 Don't have MegaVent app? Scanning will help you download it first!
🔹 After installing, scan the QR code again to register

#MegaVent #Events #${widget.event.category.replaceAll(' ', '')}

Registration Link: ${_registrationLink ?? 'Loading...'}''';
  }

  void _shareToWhatsApp() async {
    setState(() => _isSharing = true);

    try {
      final qrImageFile = await _captureQRCode();
      if (qrImageFile != null) {
        await Share.shareXFiles([
          XFile(qrImageFile.path),
        ], text: _getShareText());
      } else {
        // Fallback to text-only sharing if QR capture fails
        await Share.share(_getShareText());
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share to WhatsApp');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  void _copyLink() {
    final link = _registrationLink ?? 'Loading...';
    Clipboard.setData(ClipboardData(text: link));
    _showSuccessSnackBar('Registration link copied to clipboard!');
  }

  void _saveQRCode() async {
    setState(() => _isSharing = true);

    try {
      final qrImageFile = await _captureQRCode();
      if (qrImageFile != null) {
        await Share.shareXFiles([
          XFile(qrImageFile.path),
        ], text: 'QR Code for ${widget.event.name}');
        _showSuccessSnackBar('QR Code saved successfully!');
      } else {
        _showErrorSnackBar('Failed to capture QR code');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save QR code');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  void _shareMore() async {
    setState(() => _isSharing = true);

    try {
      final qrImageFile = await _captureQRCode();
      if (qrImageFile != null) {
        await Share.shareXFiles(
          [XFile(qrImageFile.path)],
          text: '''🎉 Register for ${widget.event.name}

📅 ${_formatEventDate()}
⏰ ${widget.event.startTime} - ${widget.event.endTime}
📍 ${widget.event.location}

🔹 Scan the QR code to automatically register
🔹 Don't have the app? Scanning will help you download it first!
🔹 After installing, scan the QR code again to register

Registration Link: ${_registrationLink ?? 'Loading...'}''',
          subject: "Event Registration - ${widget.event.name}",
        );
      } else {
        // Fallback to text-only sharing
        await Share.share(
          '''🎉 Register for ${widget.event.name}

📅 ${_formatEventDate()}
⏰ ${widget.event.startTime} - ${widget.event.endTime}
📍 ${widget.event.location}

Registration link: ${_registrationLink ?? 'Loading...'}

🔹 Don't have MegaVent app? The link will help you download it first!
🔹 After installing, scan the QR code again to register''',
          subject: "Event Registration - ${widget.event.name}",
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  Future<File?> _captureQRCode() async {
    try {
      // Wait a bit to ensure the QR code is rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final renderObject = _qrKey.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final directory = await getTemporaryDirectory();
          final file = File(
            '${directory.path}/event_qr_${widget.event.id}.png',
          );
          await file.writeAsBytes(byteData.buffer.asUint8List());
          return file;
        }
      }
    } catch (e) {
      print('Error capturing QR code: $e');
    }
    return null;
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
