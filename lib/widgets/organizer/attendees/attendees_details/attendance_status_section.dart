import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class AttendanceStatusSectionWidget extends StatelessWidget {
  final Attendee attendee;
  final Registration? registration;

  const AttendanceStatusSectionWidget({
    super.key,
    required this.attendee,
    this.registration,
  });

  // Getters that use registration data when available
  bool get hasAttended {
    return registration?.hasAttended ?? false;
  }

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
                  color: _getStatusColor(hasAttended).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasAttended
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  color: _getStatusColor(hasAttended),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance Status',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(hasAttended).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        hasAttended ? Icons.check_circle : Icons.schedule,
                        color: _getStatusColor(hasAttended),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasAttended ? 'Attended' : 'Not Attended',
                        style: TextStyle(
                          color: _getStatusColor(hasAttended),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        hasAttended ? 'Event completed' : 'Awaiting attendance',
                        style: TextStyle(
                          color: _getStatusColor(hasAttended).withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool hasAttended) {
    return hasAttended ? AppConstants.successColor : AppConstants.warningColor;
  }
}
