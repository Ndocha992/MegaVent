import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/admin.dart';
import 'package:megavent/services/database_service.dart';

class AdminPersonalInfoSection extends StatelessWidget {
  final Admin admin;
  final DatabaseService databaseService;

  const AdminPersonalInfoSection({
    super.key,
    required this.admin,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return _buildInfoSection('Personal Information', Icons.person_outline, [
      _buildInfoRow('Full Name', admin.fullName, Icons.badge_outlined),
      _buildInfoRow('Email', admin.email, Icons.email_outlined),
      _buildInfoRow(
        'Member Since',
        _formatDate(admin.createdAt),
        Icons.calendar_today_outlined,
      ),
      _buildInfoRow(
        'Last Updated',
        _formatDate(admin.updatedAt),
        Icons.update_outlined,
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
                Expanded(
                  // Added to prevent overflow
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
                      maxLines: 3, // Allow more lines for bio
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
