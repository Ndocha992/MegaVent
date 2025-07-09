import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class StaffLatestAttendeesCard extends StatefulWidget {
  final List<Attendee> attendees;
  final List<Registration> registrations;

  const StaffLatestAttendeesCard({
    super.key,
    required this.attendees,
    required this.registrations,
  });

  @override
  State<StaffLatestAttendeesCard> createState() =>
      _StaffLatestAttendeesCardState();
}

class _StaffLatestAttendeesCardState extends State<StaffLatestAttendeesCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> eventNames = {};
  bool isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _fetchEventNames();
  }

  Future<void> _fetchEventNames() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        setState(() {
          isLoadingEvents = false;
        });
        return;
      }

      // Get staff confirmed registrations first
      final staffConfirmedRegistrations =
          widget.registrations
              .where(
                (registration) =>
                    registration.confirmedBy == currentUserId &&
                    registration.hasAttended &&
                    registration.attendedAt != null,
              )
              .toList();

      if (staffConfirmedRegistrations.isEmpty) {
        setState(() {
          isLoadingEvents = false;
        });
        return;
      }

      // Get unique event IDs
      final eventIds =
          staffConfirmedRegistrations
              .map((registration) => registration.eventId)
              .toSet()
              .toList();

      // Fetch event names from Firestore
      final Map<String, String> fetchedEventNames = {};

      for (String eventId in eventIds) {
        try {
          final eventDoc =
              await _firestore.collection('events').doc(eventId).get();
          if (eventDoc.exists) {
            final eventData = eventDoc.data() as Map<String, dynamic>;
            fetchedEventNames[eventId] = eventData['name'] ?? 'Unknown Event';
          } else {
            fetchedEventNames[eventId] = 'Unknown Event';
          }
        } catch (e) {
          debugPrint('Error fetching event $eventId: $e');
          fetchedEventNames[eventId] = 'Unknown Event';
        }
      }

      setState(() {
        eventNames = fetchedEventNames;
        isLoadingEvents = false;
      });
    } catch (e) {
      debugPrint('Error fetching event names: $e');
      setState(() {
        isLoadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return _buildEmptyAttendeesState(context);
    }

    // Filter registrations to only show those confirmed by this staff member
    final staffConfirmedRegistrations =
        widget.registrations
            .where(
              (registration) =>
                  registration.confirmedBy == currentUserId &&
                  registration.hasAttended &&
                  registration.attendedAt != null,
            )
            .toList();

    // Sort by attended date (most recent first)
    staffConfirmedRegistrations.sort(
      (a, b) => (b.attendedAt ?? DateTime.now()).compareTo(
        a.attendedAt ?? DateTime.now(),
      ),
    );

    // Get the attendees for these registrations with null safety
    final staffScannedAttendees = <Map<String, dynamic>>[];
    for (final registration in staffConfirmedRegistrations.take(5)) {
      try {
        // Find the attendee by userId (not composite ID)
        final attendee = widget.attendees.cast<Attendee?>().firstWhere(
          (attendee) => attendee?.id == registration.userId,
          orElse: () => null,
        );

        if (attendee != null) {
          staffScannedAttendees.add({
            'attendee': attendee,
            'registration': registration,
          });
        } else {
          // Create a placeholder attendee if not found
          staffScannedAttendees.add({
            'attendee': Attendee(
              id: registration.userId,
              fullName: 'Unknown Attendee',
              email: 'unknown@example.com',
              phone: 'N/A',
              profileImage: null,
              isApproved: true,
              createdAt: registration.registeredAt,
              updatedAt: registration.registeredAt,
            ),
            'registration': registration,
          });
        }
      } catch (e) {
        // Log the error but continue processing other registrations
        debugPrint('Error processing registration ${registration.userId}: $e');
        continue;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Scanned Attendees', style: AppConstants.headlineSmall),
            if (staffScannedAttendees.isNotEmpty)
              Text(
                'Scanned by you',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (isLoadingEvents)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (staffScannedAttendees.isEmpty)
          _buildEmptyAttendeesState(context)
        else
          Column(
            children:
                staffScannedAttendees.map((data) {
                  final attendee = data['attendee'] as Attendee;
                  final registration = data['registration'] as Registration;
                  final eventName =
                      eventNames[registration.eventId] ?? 'Loading...';

                  return LatestAttendeeCard(
                    attendee: attendee,
                    registration: registration,
                    eventName: eventName,
                    confirmedBy: true,
                  );
                }).toList(),
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
              Icons.qr_code_scanner_outlined,
              size: 48,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Scanned Attendees Yet',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendees you scan will appear here',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/staff-scanqr');
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Start Scanning'),
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
  final bool confirmedBy;

  const LatestAttendeeCard({
    super.key,
    required this.attendee,
    required this.registration,
    required this.eventName,
    this.confirmedBy = false,
  });

  // Getters that use registration data when available
  bool get hasAttended {
    return registration?.hasAttended ?? false;
  }

  DateTime get registeredAt {
    return registration?.registeredAt ?? attendee.createdAt;
  }

  DateTime? get attendedAt {
    return registration?.attendedAt;
  }

  String get attendanceStatus {
    if (!attendee.isApproved) return 'Pending Approval';
    return hasAttended ? 'Attended' : 'Registered';
  }

  bool _isBase64(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      base64Decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildAttendeeAvatar() {
    // Handle different image sources
    if (attendee.profileImage != null && attendee.profileImage!.isNotEmpty) {
      // Check if it's base64 data
      if (_isBase64(attendee.profileImage!)) {
        return ClipOval(
          child: Image.memory(
            base64Decode(attendee.profileImage!),
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            errorBuilder:
                (context, error, stackTrace) => _buildInitialsAvatar(),
          ),
        );
      } else {
        // It's a regular URL
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
      // No image, show initials
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor:
          hasAttended ? AppConstants.successColor : AppConstants.primaryColor,
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

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else {
      return 'U';
    }
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
        // Add a subtle border for scanned attendees
        border:
            confirmedBy
                ? Border.all(
                  color: AppConstants.successColor.withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar with image or initials
                Stack(
                  children: [
                    _buildAttendeeAvatar(),
                    if (confirmedBy && hasAttended)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppConstants.successColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
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
                              attendee.fullName.isNotEmpty
                                  ? attendee.fullName
                                  : 'Unknown User',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (confirmedBy)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.successColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'SCANNED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.successColor,
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
                        attendee.phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eventName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
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
                            attendedAt != null
                                ? 'Scanned ${_formatDate(attendedAt!)}'
                                : 'Registered ${_formatDate(registeredAt)}',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
