import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerContactSectionWidget extends StatelessWidget {
  final Organizer organizer;
  final Function(String) onEmailTap;
  final Function(String) onPhoneTap;

  const OrganizerContactSectionWidget({
    super.key,
    required this.organizer,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                  borderRadius: BorderRadius.circular(8),
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
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildContactRow(
            Icons.email_outlined,
            'Email',
            organizer.email,
            onTap: () => onEmailTap(organizer.email),
          ),
          _buildContactRow(
            Icons.phone_outlined,
            'Phone',
            organizer.phone,
            onTap: () => onPhoneTap(organizer.phone),
          ),
          if (organizer.address != null && organizer.address!.isNotEmpty)
            _buildContactRow(
              Icons.location_on_outlined,
              'Address',
              organizer.address!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppConstants.primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
