import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendee_qr_dialog.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendance_status_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendee_header.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/attendee_info_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/contact_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/event_registration_section.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/qr_code_section.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class AttendeesDetails extends StatefulWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;

  const AttendeesDetails({
    super.key,
    required this.attendee,
    this.registration,
    required this.eventName,
  });

  @override
  State<AttendeesDetails> createState() => _AttendeesDetailsState();
}

class _AttendeesDetailsState extends State<AttendeesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-attendees';
  late Attendee currentAttendee;
  late Registration? currentRegistration;
  late String currentEventName;

  @override
  void initState() {
    super.initState();
    currentAttendee = widget.attendee;
    currentRegistration = widget.registration;
    currentEventName = widget.eventName;
  }

  // Getters that use registration data when available (similar to QR dialog)
  bool get hasAttended {
    return currentRegistration?.hasAttended ?? false;
  }

  DateTime get registeredAt {
    return currentRegistration?.registeredAt ?? currentAttendee.createdAt;
  }

  String get attendanceStatus {
    if (!currentAttendee.isApproved) return 'Pending Approval';
    return hasAttended ? 'Attended' : 'Registered';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentAttendee.fullName),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attendee Header with Profile
            AttendeeHeaderWidget(
              attendee: currentAttendee,
              registration: currentRegistration,
              eventName: currentEventName,
              onToggleAttendance: _toggleAttendanceStatus,
            ),

            // Attendee Information Section
            AttendeeInfoSectionWidget(
              attendee: currentAttendee,
              registration: currentRegistration,
            ),

            // Contact Information Section
            ContactSectionWidget(
              attendee: currentAttendee,
              onEmailTap: _launchEmail,
              onPhoneTap: _launchPhone,
            ),

            // Event & Registration Details
            EventRegistrationSectionWidget(
              attendee: currentAttendee,
              registration: currentRegistration,
              eventName: currentEventName,
            ),

            // Attendance Status Section
            AttendanceStatusSectionWidget(
              attendee: currentAttendee,
              registration: currentRegistration,
            ),

            // QR Code Section
            QRCodeSectionWidget(
              attendee: currentAttendee,
              registration: currentRegistration,
              onShowQRCode: _showQRCode,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showQRCode(Attendee attendee, Registration? registration) {
    showAttendeeQRDialog(context, attendee, registration, currentEventName);
  }

  void _toggleAttendanceStatus() {
    setState(() {
      if (currentRegistration != null) {
        // Update the registration's attendance status
        currentRegistration = currentRegistration!.copyWith(
          attended: !hasAttended,
          attendedAt: !hasAttended ? DateTime.now() : null,
        );
      } else {
        // If no registration exists, you might want to create one or handle this case
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasAttended
              ? '${currentAttendee.fullName} marked as attended'
              : '${currentAttendee.fullName} marked as not attended',
        ),
        backgroundColor:
            hasAttended ? AppConstants.successColor : AppConstants.warningColor,
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
