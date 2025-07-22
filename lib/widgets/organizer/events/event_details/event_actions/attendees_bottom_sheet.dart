import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/registration.dart';
import 'package:provider/provider.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/attendees/attendee_qr_dialog.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/search_bar.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/stat_card.dart';
import 'bottom_sheet_header.dart';

class AttendeesBottomSheet extends StatefulWidget {
  final Event event;

  const AttendeesBottomSheet({super.key, required this.event});

  @override
  State<AttendeesBottomSheet> createState() => _AttendeesBottomSheetState();
}

class _AttendeesBottomSheetState extends State<AttendeesBottomSheet> {
  List<Attendee> _allAttendees = [];
  List<Attendee> _filteredAttendees = [];
  List<Registration> _allRegistrations = [];
  Map<String, Registration> _userRegistrationMap = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAttendees);
    _loadAttendees();
  }

  Future<void> _loadAttendees() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Load both attendees and registrations
      final attendees = await databaseService.getEventAttendees(
        widget.event.id,
      );
      final registrations = await databaseService.getEventRegistrations(
        widget.event.id,
      );

      // FIXED: Create registration map using composite ID logic
      final userRegistrationMap = <String, Registration>{};
      for (final registration in registrations) {
        // Create composite key matching the attendee.id format
        final compositeId = '${registration.userId}_${registration.eventId}';
        userRegistrationMap[compositeId] = registration;
      }

      setState(() {
        _allAttendees = attendees;
        _filteredAttendees = attendees;
        _allRegistrations = registrations;
        _userRegistrationMap = userRegistrationMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAttendees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAttendees =
          _allAttendees.where((attendee) {
            return attendee.fullName.toLowerCase().contains(query) ||
                attendee.email.toLowerCase().contains(query) ||
                attendee.phone.toLowerCase().contains(query);
          }).toList();
    });
  }

  int get attendedCount {
    return _allRegistrations.where((reg) => reg.attended).length;
  }

  int get noShowCount {
    return _allRegistrations.length - attendedCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          BottomSheetHeader(
            icon: Icons.people,
            title: 'Event Attendees',
            subtitle: '${_allAttendees.length} registered',
            iconColor: AppConstants.successColor,
            onClose: () => Navigator.pop(context),
          ),

          // Stats Row
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StatCardWidget(
                      title: 'Registered',
                      value: '${_allAttendees.length}',
                      color: AppConstants.primaryColor,
                      icon: Icons.person_add,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCardWidget(
                      title: 'Attended',
                      value: '$attendedCount',
                      color: AppConstants.successColor,
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCardWidget(
                      title: 'No Show',
                      value: '$noShowCount',
                      color: AppConstants.errorColor,
                      icon: Icons.cancel,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Search Bar
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Search attendees by name, email, or phone...',
              ),
            ),

          const SizedBox(height: 16),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Container(
          color: AppConstants.primaryColor.withOpacity(0.1),
          child: const Center(
            child: SpinKitThreeBounce(
              color: AppConstants.primaryColor,
              size: 20.0,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading attendees',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAttendees,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredAttendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchController.text.isNotEmpty
                  ? Icons.search_off
                  : Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No attendees found matching "${_searchController.text}"'
                  : 'No attendees registered for this event yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttendees,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredAttendees.length,
        itemBuilder: (context, index) {
          final attendee = _filteredAttendees[index];
          // FIXED: Use composite ID to get the correct registration
          final registration = _userRegistrationMap[attendee.id];
          return AttendeeCard(
            attendee: attendee,
            registration: registration,
            eventName: widget.event.name,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// FIXED: Updated AttendeeCard to properly use registration data
class AttendeeCard extends StatelessWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;

  const AttendeeCard({
    super.key,
    required this.attendee,
    this.registration,
    required this.eventName,
  });

  bool _isBase64(String value) {
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
          attended ? AppConstants.successColor : AppConstants.primaryColor,
      child: Text(
        _getInitials(attendee.fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else {
      return 'U';
    }
  }

  // FIXED: Proper getters that use registration data when available
  String get attendanceStatus {
    if (!attendee.isApproved) return 'Pending Approval';
    return attended ? 'Attended' : 'Registered';
  }

  DateTime get registeredAt {
    return registration?.registeredAt ?? attendee.createdAt;
  }

  bool get attended {
    return registration?.attended ?? false;
  }

  String get qrCode {
    return registration?.qrCode ?? 'No QR Code';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar with image or initials
          _buildAttendeeAvatar(),

          const SizedBox(width: 16),

          // Attendee Details
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
                          color: AppConstants.primaryColor.withOpacity(0.1),
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
                  attendee.phone,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      attended ? Icons.check_circle : Icons.access_time,
                      size: 16,
                      color:
                          attended
                              ? AppConstants.successColor
                              : (!attendee.isApproved
                                  ? AppConstants.errorColor
                                  : Colors.orange),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attendanceStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            attended
                                ? AppConstants.successColor
                                : (!attendee.isApproved
                                    ? AppConstants.errorColor
                                    : Colors.orange),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Registered ${_formatDate(registeredAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Action Button - Show QR Code
          IconButton(
            onPressed: () {
              _showAttendeeQRDialog(context);
            },
            icon: const Icon(Icons.qr_code),
            color: AppConstants.primaryColor,
            tooltip: 'Show QR Code',
          ),
        ],
      ),
    );
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

  void _showAttendeeQRDialog(BuildContext context) {
    showAttendeeQRDialog(context, attendee, registration, eventName);
  }
}
