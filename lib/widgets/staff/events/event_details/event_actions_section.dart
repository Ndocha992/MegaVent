import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/action_card.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/attendees_bottom_sheet.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/danger_zone.dart';
import 'package:megavent/widgets/organizer/events/event_details/event_actions/share_event_bottom_sheet.dart';

class EventActionsSection extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventActionsSection({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required bool isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Event'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary Actions Grid
          Row(
            children: [
              Expanded(
                child: ActionCardWidget(
                  icon: Icons.share,
                  title: 'Share Event',
                  subtitle: 'Share with others',
                  onTap: () => _handleShare(context),
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionCardWidget(
                  icon: Icons.people,
                  title: 'Attendees',
                  subtitle: '${event.registeredCount} registered',
                  onTap: () => _handleViewAttendees(context),
                  color: AppConstants.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Danger Zone
          DangerZoneWidget(onDelete: onDelete),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => ShareEventBottomSheet(event: event),
    );
  }

  void _handleViewAttendees(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => AttendeesBottomSheet(event: event),
    );
  }
}
