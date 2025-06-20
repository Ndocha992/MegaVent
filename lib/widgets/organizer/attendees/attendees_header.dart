import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/organizer/attendees/attendees_utils.dart';

class AttendeesHeader extends StatelessWidget {
  const AttendeesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendees Management',
                    style: AppConstants.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and manage event attendees',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              AttendeesCountBadge(count: FakeData.attendees.length),
            ],
          ),
          const SizedBox(height: 16),
          const AttendeesStatsRow(),
        ],
      ),
    );
  }
}

class AttendeesCountBadge extends StatelessWidget {
  final int count;

  const AttendeesCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppConstants.primaryGradient),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            '$count Attendees',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendeesStatsRow extends StatelessWidget {
  const AttendeesStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = AttendeesUtils.getAttendeesStats(FakeData.attendees);

    return Row(
      children: [
        AttendeeStatCard(
          label: 'Registered',
          count: stats.registered,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 12),
        AttendeeStatCard(
          label: 'Attended',
          count: stats.attended,
          color: AppConstants.successColor,
        ),
        const SizedBox(width: 12),
        AttendeeStatCard(
          label: 'No Show',
          count: stats.noShow,
          color: AppConstants.errorColor,
        ),
      ],
    );
  }
}

class AttendeeStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const AttendeeStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
