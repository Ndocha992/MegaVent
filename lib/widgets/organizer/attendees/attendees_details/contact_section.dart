import 'package:flutter/material.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_details/contact_row.dart';

class ContactSectionWidget extends StatelessWidget {
  final Attendee attendee;
  final Function(String) onEmailTap;
  final Function(String) onPhoneTap;

  const ContactSectionWidget({
    super.key,
    required this.attendee,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

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
                  Icons.contact_mail_outlined,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Email
          ContactRowWidget(
            icon: Icons.email_outlined,
            label: 'Email',
            value: attendee.email,
            onTap: () => onEmailTap(attendee.email),
          ),
          const SizedBox(height: 16),

          // Phone
          ContactRowWidget(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: attendee.phone,
            onTap: () => onPhoneTap(attendee.phone),
          ),
        ],
      ),
    );
  }
}