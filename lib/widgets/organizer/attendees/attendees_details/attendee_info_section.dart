import 'package:flutter/material.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/info_row.dart';

class AttendeeInfoSectionWidget extends StatelessWidget {
  final Attendee attendee;

  const AttendeeInfoSectionWidget({
    super.key,
    required this.attendee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
                  Icons.person_outline,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendee Information',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          InfoRowWidget(label: 'Full Name', value: attendee.name),
          InfoRowWidget(
            label: 'Registration Status',
            value: attendee.hasAttended ? 'Attended' : 'Registered',
          ),
        ],
      ),
    );
  }
}