import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/staff/events/event_details/event_actions/action_card.dart';
import 'package:megavent/widgets/staff/events/event_details/event_actions/attendees_bottom_sheet.dart';
import 'package:megavent/widgets/staff/events/event_details/event_actions/share_event_bottom_sheet.dart';

class StaffEventActionsSection extends StatelessWidget {
  final Event event;

  const StaffEventActionsSection({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          // Actions Grid
          Row(
            children: [
              Expanded(
                child: StaffActionCardWidget(
                  icon: Icons.share,
                  title: 'Share Event',
                  subtitle: 'Share with others',
                  onTap: () => _handleShare(context),
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StaffActionCardWidget(
                  icon: Icons.people,
                  title: 'Attendees',
                  subtitle: '${event.registeredCount} registered',
                  onTap: () => _handleViewAttendees(context),
                  color: AppConstants.successColor,
                ),
              ),
            ],
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
          (BuildContext context) => StaffShareEventBottomSheet(event: event),
    );
  }

  void _handleViewAttendees(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => StaffAttendeesBottomSheet(event: event),
    );
  }
}
