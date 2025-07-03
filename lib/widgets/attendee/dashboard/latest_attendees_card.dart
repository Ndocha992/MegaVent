import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/screens/organizer/attendees_details.dart';

class LatestAttendeesCard extends StatelessWidget {
  final List<Attendee> attendees;
  final List<Registration> registrations;
  final Map<String, String> eventNames;

  const LatestAttendeesCard({
    super.key,
    required this.attendees,
    required this.registrations,
    required this.eventNames,
  });

  void _onAttendeeTap(BuildContext context, Attendee attendee) {
    // Create registration map for quick lookup
    final Map<String, Registration> userRegistrationMap = {};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    // Get the registration for this attendee
    final Registration? attendeeRegistration = userRegistrationMap[attendee.id];
    
    // Get the event name for this attendee
    final String eventName = eventNames[attendeeRegistration?.eventId] ?? 'Unknown Event';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendeesDetails(
          attendee: attendee,
          registration: attendeeRegistration,
          eventName: eventName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create registration map for quick lookup
    final Map<String, Registration> userRegistrationMap = {};
    for (final registration in registrations) {
      userRegistrationMap[registration.userId] = registration;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Attendees', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/organizer-attendees');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        attendees.isEmpty
            ? _buildEmptyAttendeesState(context)
            : Column(
              children:
                  attendees
                      .map(
                        (attendee) => LatestAttendeeCard(
                          attendee: attendee,
                          registration: userRegistrationMap[attendee.id],
                          eventName:
                              eventNames[userRegistrationMap[attendee.id]
                                  ?.eventId] ??
                              'Unknown Event',
                          onTap: () => _onAttendeeTap(context, attendee),
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }

  Widget _buildEmptyAttendeesState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_alt_outlined,
              size: 48,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Attendees Yet',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendees will appear here once they register for your events',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/organizer-attendees');
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Attendees'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatestAttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;
  final VoidCallback onTap;

  const LatestAttendeeCard({
    super.key,
    required this.attendee,
    required this.registration,
    required this.eventName,
    required this.onTap,
  });

  // Getters that use registration data when available (similar to AttendeeQRDialog)
  bool get hasAttended {
    return registration?.hasAttended ?? false;
  }

  DateTime get registeredAt {
    return registration?.registeredAt ?? attendee.createdAt;
  }

  String get attendanceStatus {
    if (!attendee.isApproved) return 'Pending Approval';
    return hasAttended ? 'Attended' : 'Registered';
  }

  bool _isBase64(String? value) {
    if (value == null || value.isEmpty) return false;

    try {
      // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
      String base64String = value;
      if (value.contains(',')) {
        base64String = value.split(',').last;
      }

      // Check if it's a valid base64 string
      if (base64String.isEmpty) return false;

      // Try to decode
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  String _getBase64Data(String value) {
    // Remove data URL prefix if present
    if (value.contains(',')) {
      return value.split(',').last;
    }
    return value;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Widget _buildAvatarContent() {
    // Handle different image sources
    if (attendee.profileImage != null && attendee.profileImage!.isNotEmpty) {
      // Check if it's base64 data
      if (_isBase64(attendee.profileImage)) {
        try {
          return ClipOval(
            child: Image.memory(
              base64Decode(_getBase64Data(attendee.profileImage!)),
              fit: BoxFit.cover,
              width: 48,
              height: 48,
              errorBuilder:
                  (context, error, stackTrace) => _buildInitialsAvatar(),
            ),
          );
        } catch (e) {
          return _buildInitialsAvatar();
        }
      } else {
        return ClipOval(
          child: Image.network(
            attendee.profileImage!,
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            errorBuilder:
                (context, error, stackTrace) => _buildInitialsAvatar(),
          ),
        );
      }
    } else {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _getInitials(attendee.fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            hasAttended
                                ? AppConstants.successColor
                                : AppConstants.primaryColor,
                      ),
                      child: _buildAvatarContent(),
                    ),
                    if (attendee.isNew)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppConstants.successColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.white, spreadRadius: 1),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              attendee.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (attendee.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendee.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eventName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            hasAttended
                                ? Icons.check_circle
                                : Icons.access_time,
                            size: 16,
                            color:
                                hasAttended
                                    ? AppConstants.successColor
                                    : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasAttended ? 'Attended' : 'Not Attended',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  hasAttended
                                      ? AppConstants.successColor
                                      : Colors.orange,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Registered ${_formatDate(registeredAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}