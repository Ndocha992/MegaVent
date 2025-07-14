import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerOrganizationSectionWidget extends StatelessWidget {
  final Organizer organizer;

  const OrganizerOrganizationSectionWidget({
    super.key,
    required this.organizer,
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
                  Icons.business_outlined,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Organization Information',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (organizer.organization != null)
            _buildInfoRow('Organization Name', organizer.organization!),
          if (organizer.website != null)
            _buildInfoRow('Website', organizer.website!),

          // If no organization info is available
          if (organizer.organization == null) _buildNoOrganizationInfo(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrganizationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppConstants.textSecondaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppConstants.textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No organization information provided',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
