import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'bottom_sheet_header.dart';
import 'package:intl/intl.dart';

class AttendeeRegisterEventBottomSheet extends StatefulWidget {
  final Event event;

  const AttendeeRegisterEventBottomSheet({super.key, required this.event});

  @override
  State<AttendeeRegisterEventBottomSheet> createState() =>
      _AttendeeRegisterEventBottomSheetState();
}

class _AttendeeRegisterEventBottomSheetState
    extends State<AttendeeRegisterEventBottomSheet> {
  bool _isRegistering = false;
  bool _isRegistered = false;
  bool _isLoading = true;
  late DatabaseService _databaseService;
  String? _errorMessage;

  // Check if event has ended
  bool _isEventEnded() {
    final now = DateTime.now();
    final eventEnd = widget.event.endDate;

    // Create DateTime object for event end using its date + end time
    final endTimeParts = widget.event.endTime.split(':');
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1].split(' ')[0]);
    final isPM = widget.event.endTime.contains('PM') && endHour != 12;
    final eventEndDateTime = DateTime(
      eventEnd.year,
      eventEnd.month,
      eventEnd.day,
      isPM ? endHour + 12 : endHour,
      endMinute,
    );

    return eventEndDateTime.isBefore(now);
  }

  // Show event ended dialog
  void _showEventEndedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.event_busy, color: AppConstants.errorColor),
              const SizedBox(width: 8),
              const Text('Event Has Ended'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sorry, registration is no longer available for this event.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event: ${widget.event.name}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ended: ${_formatEventDate()}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _checkRegistrationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          AttendeeBottomSheetHeader(
            icon: Icons.person_add,
            title: 'Event Registration',
            subtitle: _isRegistered ? 'You\'re registered!' : 'Join this event',
            iconColor:
                _isRegistered
                    ? AppConstants.successColor
                    : AppConstants.primaryColor,
            onClose: () => Navigator.pop(context),
          ),

          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: SpinKitThreeBounce(
                        color: AppConstants.primaryColor,
                        size: 24.0,
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildEventInfoCard(),
                          const SizedBox(height: 24),
                          _buildRegistrationInfo(),
                          const SizedBox(height: 24),
                          _buildRegistrationButton(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    widget.event.category,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.event.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getCategoryColor(widget.event.category),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(widget.event.startDate, widget.event.startTime),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Ends: ${_formatDateTime(widget.event.endDate, widget.event.endTime)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Registration Status
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${widget.event.registeredCount}/${widget.event.capacity} registered',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getEventStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getEventStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getEventStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationInfo() {
    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppConstants.errorColor, size: 48),
            const SizedBox(height: 12),
            Text(
              'Registration Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_isRegistered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: AppConstants.successColor,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'You\'re Registered!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully registered for this event. Check your email for confirmation details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppConstants.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Registration Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.event.description.isNotEmpty)
            _buildInfoRow('Description', widget.event.description, maxLines: 3),
          _buildInfoRow('Available Spots', '${widget.event.availableSpots}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationButton() {
    if (_isRegistered) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.check),
              label: const Text('Already Registered'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.successColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppConstants.successColor,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Check if event has ended
    if (_isEventEnded()) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _showEventEndedDialog(),
          icon: const Icon(Icons.event_busy),
          label: const Text('Event Has Ended'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.errorColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    if (_isEventFull()) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.block),
          label: const Text('Event Full'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isRegistering ? null : _handleRegistration,
        icon:
            _isRegistering
                ? SpinKitThreeBounce(color: Colors.white, size: 16.0)
                : const Icon(Icons.person_add),
        label: Text(_isRegistering ? 'Registering...' : 'Register for Event'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _formatEventDate() {
    final startDate = widget.event.startDate;
    final endDate = widget.event.endDate;

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // Same day event
      return DateFormat('EEEE, MMMM d, yyyy').format(startDate);
    } else {
      // Multi-day event
      return '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return AppConstants.textSecondaryColor;

      // Business & Professional
      case 'technology':
        return const Color(0xFF2196F3); // Blue
      case 'business':
        return const Color(0xFF4CAF50); // Green
      case 'conference':
        return const Color(0xFF9C27B0); // Purple
      case 'seminar':
        return const Color(0xFF795548); // Brown
      case 'workshop':
        return const Color(0xFFFF9800); // Orange
      case 'networking':
        return const Color(0xFF607D8B); // Blue Grey
      case 'trade show':
        return const Color(0xFF00BCD4); // Cyan
      case 'expo':
        return const Color(0xFF3F51B5); // Indigo

      // Entertainment & Arts
      case 'music':
        return const Color(0xFFE91E63); // Pink
      case 'arts & culture':
        return const Color(0xFF9C27B0); // Purple
      case 'theater & performing arts':
        return const Color(0xFF673AB7); // Deep Purple
      case 'comedy shows':
        return const Color(0xFFFFC107); // Amber
      case 'film & cinema':
        return const Color(0xFF424242); // Grey
      case 'fashion':
        return const Color(0xFFE91E63); // Pink
      case 'entertainment':
        return const Color(0xFFFF5722); // Deep Orange

      // Community & Cultural
      case 'cultural festival':
        return const Color(0xFF8BC34A); // Light Green
      case 'community event':
        return const Color(0xFF4CAF50); // Green
      case 'religious event':
        return const Color(0xFF795548); // Brown
      case 'traditional ceremony':
        return const Color(0xFF607D8B); // Blue Grey
      case 'charity & fundraising':
        return const Color(0xFF4CAF50); // Green
      case 'cultural exhibition':
        return const Color(0xFF9C27B0); // Purple

      // Sports & Recreation
      case 'sports & recreation':
        return const Color(0xFF2196F3); // Blue
      case 'football (soccer)':
        return const Color(0xFF4CAF50); // Green
      case 'rugby':
        return const Color(0xFF795548); // Brown
      case 'athletics':
        return const Color(0xFFFF9800); // Orange
      case 'marathon & running':
        return const Color(0xFFF44336); // Red
      case 'outdoor adventure':
        return const Color(0xFF8BC34A); // Light Green
      case 'safari rally':
        return const Color(0xFF795548); // Brown
      case 'water sports':
        return const Color(0xFF2196F3); // Blue

      // Education & Development
      case 'education':
        return const Color(0xFF3F51B5); // Indigo
      case 'training & development':
        return const Color(0xFF009688); // Teal
      case 'youth programs':
        return const Color(0xFFFF9800); // Orange
      case 'academic conference':
        return const Color(0xFF673AB7); // Deep Purple
      case 'skill development':
        return const Color(0xFF00BCD4); // Cyan

      // Health & Wellness
      case 'health & wellness':
        return const Color(0xFF4CAF50); // Green
      case 'medical conference':
        return const Color(0xFFF44336); // Red
      case 'fitness & yoga':
        return const Color(0xFF8BC34A); // Light Green
      case 'mental health':
        return const Color(0xFF9C27B0); // Purple

      // Food & Agriculture
      case 'food & drink':
        return const Color(0xFFFF9800); // Orange
      case 'agricultural show':
        return const Color(0xFF8BC34A); // Light Green
      case 'food festival':
        return const Color(0xFFFF5722); // Deep Orange
      case 'cooking workshop':
        return const Color(0xFFFFC107); // Amber
      case 'wine tasting':
        return const Color(0xFF9C27B0); // Purple

      // Travel & Tourism
      case 'travel':
        return const Color(0xFF2196F3); // Blue
      case 'tourism promotion':
        return const Color(0xFF00BCD4); // Cyan
      case 'adventure tourism':
        return const Color(0xFF4CAF50); // Green
      case 'wildlife conservation':
        return const Color(0xFF8BC34A); // Light Green

      // Government & Politics
      case 'government event':
        return const Color(0xFF3F51B5); // Indigo
      case 'political rally':
        return const Color(0xFFF44336); // Red
      case 'public forum':
        return const Color(0xFF607D8B); // Blue Grey
      case 'civic engagement':
        return const Color(0xFF009688); // Teal

      // Special Occasions
      case 'wedding':
        return const Color(0xFFE91E63); // Pink
      case 'birthday party':
        return const Color(0xFFFFC107); // Amber
      case 'anniversary':
        return const Color(0xFF9C27B0); // Purple
      case 'graduation':
        return const Color(0xFF3F51B5); // Indigo
      case 'baby shower':
        return const Color(0xFFFFEB3B); // Yellow
      case 'corporate party':
        return const Color(0xFF607D8B); // Blue Grey

      // Seasonal & Holiday
      case 'christmas event':
        return const Color(0xFFF44336); // Red
      case 'new year celebration':
        return const Color(0xFFFFC107); // Amber
      case 'independence day':
        return const Color(0xFF4CAF50); // Green
      case 'eid celebration':
        return const Color(0xFF9C27B0); // Purple
      case 'diwali':
        return const Color(0xFFFF9800); // Orange
      case 'easter event':
        return const Color(0xFF8BC34A); // Light Green

      // Markets & Shopping
      case 'market event':
        return const Color(0xFF795548); // Brown
      case 'craft fair':
        return const Color(0xFFFF9800); // Orange
      case 'farmers market':
        return const Color(0xFF8BC34A); // Light Green
      case 'pop-up shop':
        return const Color(0xFFE91E63); // Pink

      // Other
      case 'other':
        return AppConstants.textSecondaryColor;

      default:
        return AppConstants.primaryColor;
    }
  }

  // Helper method to format date and time together
  String _formatDateTime(DateTime date, String time) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date) + ' at $time';
  }

  // Helper methods for event status
  String _getEventStatusText() {
    if (_isEventEnded()) return 'Ended';
    if (_isEventFull()) return 'Full';
    return 'Open';
  }

  // Status color
  Color _getEventStatusColor() {
    if (_isEventEnded()) return AppConstants.errorColor;
    if (_isEventFull()) return AppConstants.warningColor;
    return AppConstants.successColor;
  }

  bool _isEventFull() {
    return widget.event.registeredCount >= widget.event.capacity;
  }

  void _checkRegistrationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Please log in to register for events';
          _isLoading = false;
        });
        return;
      }

      final isRegistered = await _databaseService.isUserRegisteredForEvent(
        user.uid,
        widget.event.id,
      );

      setState(() {
        _isRegistered = isRegistered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking registration status: ${e.toString()}';
        _isLoading = false;
      });
      print('Error checking registration status: $e');
    }
  }

  void _handleRegistration() async {
    if (_isEventFull() || _isRegistered) return;

    // Check if event has ended before proceeding
    if (_isEventEnded()) {
      _showEventEndedDialog();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please log in to register for events');
      return;
    }

    setState(() {
      _isRegistering = true;
      _errorMessage = null;
    });

    try {
      await _databaseService.registerUserForEvent(user.uid, widget.event.id);

      // Update local state to reflect successful registration
      setState(() {
        _isRegistered = true;
        _isRegistering = false;
      });

      _showSuccessSnackBar('Successfully registered for ${widget.event.name}!');

      // Auto-close after successful registration (optional)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate successful registration
        }
      });
    } catch (e) {
      setState(() {
        _isRegistering = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
