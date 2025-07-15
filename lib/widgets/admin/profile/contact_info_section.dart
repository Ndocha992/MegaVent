import 'package:flutter/material.dart';
import 'package:megavent/models/admin.dart';
import 'package:megavent/utils/constants.dart';

class AdminContactInfoSection extends StatelessWidget {
  final Admin admin;
  final Function(String) onEmailTap;
  final Function(String) onPhoneTap;

  const AdminContactInfoSection({
    super.key,
    required this.admin,
    required this.onEmailTap,
    required this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildInfoSection(
      'Contact Information',
      Icons.contact_mail_outlined,
      [
        _buildInfoRow(
          'Email',
          admin.email,
          Icons.email_outlined,
          onTap: () => onEmailTap(admin.email),
        ),
        _buildInfoRow(
          'Phone',
          admin.phone,
          Icons.phone_outlined,
          onTap: () => onPhoneTap(admin.phone),
        ),
      ],
    );
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
