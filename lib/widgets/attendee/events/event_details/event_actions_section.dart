import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/action_card.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/share_event_bottom_sheet.dart';
import 'package:megavent/widgets/attendee/events/event_details/event_actions/register_event_bottom_sheet.dart';

class AttendeeEventActionsSection extends StatelessWidget {
  final Event event;

  const AttendeeEventActionsSection({super.key, required this.event});

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
                child: AttendeeActionCardWidget(
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

  void _handleShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => AttendeeShareEventBottomSheet(event: event),
    );
  }

  void _handleRegisterEvent(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) =>
              AttendeeRegisterEventBottomSheet(event: event),
    );
  }
}
