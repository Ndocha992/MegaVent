import 'package:flutter/material.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeHeaderWidget extends StatelessWidget {
  final Attendee attendee;
  final VoidCallback? onToggleAttendance;

  const AttendeeHeaderWidget({
    super.key,
    required this.attendee,
    this.onToggleAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(attendee.name),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              attendee.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Event Name
            Text(
              attendee.eventName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 12),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(attendee.hasAttended),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                attendee.hasAttended ? 'ATTENDED' : 'REGISTERED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Color _getStatusColor(bool hasAttended) {
    return hasAttended ? AppConstants.successColor : AppConstants.warningColor;
  }
}