import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class StaffDepartmentRoleSectionWidget extends StatelessWidget {
  final Staff staff;

  const StaffDepartmentRoleSectionWidget({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              'Department',
              staff.department,
              Icons.business_outlined,
              _getDepartmentColor(staff.department),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatsCard(
              'Role',
              staff.role,
              Icons.work_outline,
              AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'operations':
        return AppConstants.primaryColor;
      case 'creative':
        return AppConstants.successColor;
      case 'technical':
        return AppConstants.warningColor;
      case 'marketing':
        return AppConstants.errorColor;
      default:
        return AppConstants.primaryColor;
    }
  }
}