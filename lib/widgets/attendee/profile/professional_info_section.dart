import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/organizer.dart';

class ProfessionalInfoSection extends StatelessWidget {
  final Organizer organizer;
  final Function(String) onWebsiteTap;

  const ProfessionalInfoSection({
    super.key,
    required this.organizer,
    required this.onWebsiteTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildInfoSection('Professional Information', Icons.work_outline, [
      _buildInfoRow(
        'Organization',
        organizer.organization ?? 'Not specified',
        Icons.business_outlined,
      ),
      _buildInfoRow(
        'Job Title',
        organizer.jobTitle ?? 'Not specified',
        Icons.badge_outlined,
      ),
      _buildInfoRow(
        'Website',
        organizer.website ?? 'Not added',
        Icons.web_outlined,
        onTap: organizer.website != null
            ? () => onWebsiteTap(organizer.website!)
            : null,
      ),
    ]);
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: AppConstants.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced padding
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
                  child: Icon(icon, color: AppConstants.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded( // Added to prevent overflow
                  child: Text(
                    title,
                    style: AppConstants.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppConstants.textSecondaryColor),
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
                      style: AppConstants.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppConstants.textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}