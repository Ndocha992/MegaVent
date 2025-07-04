import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/action_card.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/share_event_bottom_sheet.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/register_event_bottom_sheet.dart';
import 'package:megavent/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AttendeeEventActionsSection extends StatefulWidget {
  final Event event;
  final bool isRegisteredEvent; // New parameter to determine context

  const AttendeeEventActionsSection({
    super.key,
    required this.event,
    this.isRegisteredEvent =
        false, // Default to false for backward compatibility
  });

  @override
  State<AttendeeEventActionsSection> createState() =>
      _AttendeeEventActionsSectionState();
}

class _AttendeeEventActionsSectionState
    extends State<AttendeeEventActionsSection> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          // Primary Actions Grid
          Row(
            children: [
              Expanded(
                child:
                    widget.isRegisteredEvent
                        ? _isLoading
                            ? _buildLoadingCard()
                            : AttendeeActionCardWidget(
                              icon: Icons.person_remove,
                              title: 'Unregister',
                              subtitle: 'Remove registration',
                              onTap: () => _handleUnregisterEvent(context),
                              color: AppConstants.errorColor,
                            )
                        : AttendeeActionCardWidget(
                          icon: Icons.person_add,
                          title: 'Register',
                          subtitle: 'Join this event',
                          onTap: () => _handleRegisterEvent(context),
                          color: AppConstants.successColor,
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AttendeeActionCardWidget(
                  icon: Icons.share,
                  title: 'Share Event',
                  subtitle: 'Share with friends',
                  onTap: () => _handleShare(context),
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 32, color: AppConstants.errorColor),
          const SizedBox(height: 12),
          SpinKitThreeBounce(color: AppConstants.primaryColor, size: 20.0),
          const SizedBox(height: 8),
          Text(
            'Removing...',
            style: TextStyle(
              color: AppConstants.errorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) =>
              AttendeeShareEventBottomSheet(event: widget.event),
    );
  }

  void _handleRegisterEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) =>
              AttendeeRegisterEventBottomSheet(event: widget.event),
    );
  }

  void _handleUnregisterEvent(BuildContext context) {
    // Don't show dialog if already loading
    if (_isLoading) return;

    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppConstants.errorColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Confirm Unregistration'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to unregister from this event?',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
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
                        widget.event.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.event.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This action cannot be undone. You will need to register again if you change your mind.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performUnregistration();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Unregister'),
              ),
            ],
          ),
    );
  }

  void _performUnregistration() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please log in to unregister from events');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );
      await databaseService.unregisterUserFromEvent(user.uid, widget.event.id);

      setState(() {
        _isLoading = false;
      });

      _showSuccessSnackBar(
        'Successfully unregistered from ${widget.event.name}',
      );

      // Navigate to My Events screen and refresh data
      await _navigateToMyEventsScreen();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _navigateToMyEventsScreen() async {
    if (mounted) {
      // Navigate to My Events screen with route replacement
      // This will clear the current screen from the stack and go to My Events
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/attendee-my-events',
        (Route<dynamic> route) => false, // Remove all previous routes
      );

      // Alternative approach if you want to keep some navigation history:
      // Navigator.of(context).pushReplacementNamed('/attendee-my-events');

      // Or if you want to pop to the My Events screen if it's already in the stack:
      // Navigator.of(context).popUntil(
      //   (route) => route.settings.name == '/attendee-my-events'
      // );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
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
              const Icon(Icons.error_outline, color: Colors.white),
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
