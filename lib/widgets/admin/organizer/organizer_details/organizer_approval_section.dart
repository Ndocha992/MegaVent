import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerApprovalSectionWidget extends StatelessWidget {
  final Organizer organizer;
  final VoidCallback onApprovalToggle;

  const OrganizerApprovalSectionWidget({
    super.key,
    required this.organizer,
    required this.onApprovalToggle,
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
                  Icons.verified_user_outlined,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Approval Management',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  organizer.isApproved
                      ? AppConstants.successColor.withOpacity(0.1)
                      : AppConstants.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    organizer.isApproved
                        ? AppConstants.successColor.withOpacity(0.3)
                        : AppConstants.warningColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  organizer.isApproved ? Icons.check_circle : Icons.pending,
                  color:
                      organizer.isApproved
                          ? AppConstants.successColor
                          : AppConstants.warningColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organizer.isApproved ? 'Approved' : 'Pending Approval',
                        style: AppConstants.bodyMedium.copyWith(
                          color:
                              organizer.isApproved
                                  ? AppConstants.successColor
                                  : AppConstants.warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        organizer.isApproved
                            ? 'This organizer can create and manage events'
                            : 'This organizer cannot create events until approved',
                        style: AppConstants.bodySmall.copyWith(
                          color:
                              organizer.isApproved
                                  ? AppConstants.successColor.withOpacity(0.8)
                                  : AppConstants.warningColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Approval Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApprovalToggle,
              icon: Icon(
                organizer.isApproved
                    ? Icons.remove_circle_outline
                    : Icons.check_circle_outline,
              ),
              label: Text(
                organizer.isApproved ? 'Revoke Approval' : 'Approve Organizer',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    organizer.isApproved
                        ? AppConstants.errorColor
                        : AppConstants.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
