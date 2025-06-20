import 'package:flutter/material.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendee_qr_dialog.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendance_status_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendee_header.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendee_info_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/contact_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/event_registration_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/qr_code_section.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class AttendeesDetails extends StatefulWidget {
  final Attendee attendee;

  const AttendeesDetails({super.key, required this.attendee});

  @override
  State<AttendeesDetails> createState() => _AttendeesDetailsState();
}

class _AttendeesDetailsState extends State<AttendeesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-attendees';
  late Attendee currentAttendee;

  @override
  void initState() {
    super.initState();
    currentAttendee = widget.attendee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentAttendee.name),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendee Header with Profile
            AttendeeHeaderWidget(
              attendee: currentAttendee,
              onToggleAttendance: _toggleAttendanceStatus,
            ),

            // Attendee Information Section
            AttendeeInfoSectionWidget(attendee: currentAttendee),

            // Contact Information Section
            ContactSectionWidget(
              attendee: currentAttendee,
              onEmailTap: _launchEmail,
              onPhoneTap: _launchPhone,
            ),

            // Event & Registration Details
            EventRegistrationSectionWidget(attendee: currentAttendee),

            // Attendance Status Section
            AttendanceStatusSectionWidget(attendee: currentAttendee),

            // QR Code Section
            QRCodeSectionWidget(
              attendee: currentAttendee,
              onShowQRCode: _showQRCode,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showQRCode(Attendee attendee) {
    showDialog(
      context: context,
      builder: (context) => AttendeeQRDialog(attendee: attendee),
    );
  }

  void _toggleAttendanceStatus() {
    setState(() {
      currentAttendee = Attendee(
        id: currentAttendee.id,
        name: currentAttendee.name,
        email: currentAttendee.email,
        phone: currentAttendee.phone,
        eventId: currentAttendee.eventId,
        eventName: currentAttendee.eventName,
        qrCode: currentAttendee.qrCode,
        hasAttended: !currentAttendee.hasAttended,
        registeredAt: currentAttendee.registeredAt,
        isNew: currentAttendee.isNew,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          currentAttendee.hasAttended
              ? '${currentAttendee.name} marked as attended'
              : '${currentAttendee.name} marked as not attended',
        ),
        backgroundColor:
            currentAttendee.hasAttended
                ? AppConstants.successColor
                : AppConstants.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _launchEmail(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email to $email'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
