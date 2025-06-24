import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class StaffInfoSectionWidget extends StatelessWidget {
  final Staff staff;

  const StaffInfoSectionWidget({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
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
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Staff Information',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoRow('Full Name', staff.name),
          _buildInfoRow('Role', staff.role),
          _buildInfoRow('Department', staff.department),
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
}