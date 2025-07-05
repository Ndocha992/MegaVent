import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/info_row.dart';
import 'package:intl/intl.dart';

class EventRegistrationSectionWidget extends StatelessWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;

  const EventRegistrationSectionWidget({
    super.key,
    required this.attendee,
    this.registration,
    required this.eventName,
  });

  // Getters that use registration data when available
  DateTime get registeredAt {
    return registration?.registeredAt ?? attendee.createdAt;
  }

  String get eventId {
    return registration?.eventId ?? 'Unknown';
  }

  String _getFormattedRegistrationDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy \'at\' HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_outlined,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Event & Registration',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          InfoRowWidget(label: 'Event Name', value: eventName),
          InfoRowWidget(label: 'Event ID', value: eventId),
          InfoRowWidget(
            label: 'Registration Date',
            value: _getFormattedRegistrationDate(registeredAt),
          ),
        ],
      ),
    );
  }
}
