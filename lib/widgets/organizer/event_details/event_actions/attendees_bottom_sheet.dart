import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/event_details/event_actions/search_bar.dart';
import 'package:megavent/widgets/organizer/event_details/event_actions/stat_card.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Filter attendees for the current event
    _allAttendees =
        FakeData.attendees
            .where((attendee) => attendee.eventId == widget.event.id)
            .toList();
    _filteredAttendees = _allAttendees;
    _searchController.addListener(_filterAttendees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAttendees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAttendees =
          _allAttendees.where((attendee) {
            return attendee.name.toLowerCase().contains(query) ||
                attendee.email.toLowerCase().contains(query) ||
                attendee.phone.toLowerCase().contains(query);
          }).toList();
    });
  }

  int get attendedCount {
    return _allAttendees.where((attendee) => attendee.hasAttended).length;
  }

  int get noShowCount {
    return _allAttendees.length - attendedCount;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search attendees by name, email, or phone...',
            ),
          ),

          const SizedBox(height: 16),

          // Attendees List
          Expanded(
            child:
                _filteredAttendees.isEmpty
                    ? Center(
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredAttendees.length,
                      itemBuilder: (context, index) {
                        final attendee = _filteredAttendees[index];
                        return AttendeeCard(attendee: attendee);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// Updated AttendeeCard to work with Attendee objects
class AttendeeCard extends StatelessWidget {
  final Attendee attendee;

  const AttendeeCard({super.key, required this.attendee});

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
          // Profile Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor:
                attendee.hasAttended
                    ? AppConstants.successColor
                    : AppConstants.primaryColor,
            child: Text(
              attendee.name.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

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
                        attendee.name,
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
                      attendee.hasAttended
                          ? Icons.check_circle
                          : Icons.access_time,
                      size: 16,
                      color:
                          attendee.hasAttended
                              ? AppConstants.successColor
                              : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attendee.hasAttended ? 'Attended' : 'Not Attended',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            attendee.hasAttended
                                ? AppConstants.successColor
                                : Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Registered ${_formatDate(attendee.registeredAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Action Button
          IconButton(
            onPressed: () {
              // Handle QR code or more details
              _showAttendeeDetails(context, attendee);
            },
            icon: const Icon(Icons.qr_code),
            color: AppConstants.primaryColor,
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

  void _showAttendeeDetails(BuildContext context, Attendee attendee) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(attendee.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Email', attendee.email),
                _buildDetailRow('Phone', attendee.phone),
                _buildDetailRow('QR Code', attendee.qrCode),
                _buildDetailRow(
                  'Status',
                  attendee.hasAttended ? 'Attended' : 'Not Attended',
                ),
                _buildDetailRow(
                  'Registered',
                  _formatDate(attendee.registeredAt),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
