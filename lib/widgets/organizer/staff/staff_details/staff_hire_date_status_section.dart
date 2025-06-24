import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class StaffHireDateStatusSectionWidget extends StatelessWidget {
  final Staff staff;

  const StaffHireDateStatusSectionWidget({
    super.key,
    required this.staff,
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
                  Icons.schedule_outlined,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Employment Details',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoRow('Hired Date', _formatDate(staff.hiredAt)),
          _buildInfoRow(
            'Time with Company',
            _getTimeWithCompany(staff.hiredAt),
          ),
          _buildInfoRow(
            'Status',
            staff.isNew ? 'New Employee' : 'Active',
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimeWithCompany(DateTime hiredDate) {
    final now = DateTime.now();
    final difference = now.difference(hiredDate);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }
}