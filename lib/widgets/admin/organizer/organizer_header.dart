import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/staff.dart';
import 'package:provider/provider.dart';

class OrganizerHeader extends StatelessWidget {
  const OrganizerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );

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
                  Text('Organizer Management', style: AppConstants.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your organizers',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              StreamBuilder<List<Staff>>(
                stream: databaseService.streamStaff(),
                builder: (context, snapshot) {
                  final staffCount = snapshot.data?.length ?? 0;
                  return OrganizerCountBadge(count: staffCount);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Staff>>(
            stream: databaseService.streamStaff(),
            builder: (context, snapshot) {
              final staffList = snapshot.data ?? [];
              return OrganizerStatsRow(staffList: staffList);
            },
          ),
        ],
      ),
    );
  }
}

class OrganizerCountBadge extends StatelessWidget {
  final int count;

  const OrganizerCountBadge({super.key, required this.count});

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
          const Icon(Icons.people, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            '$count Organizers',
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

class OrganizerStatsRow extends StatelessWidget {
  final List<Staff> staffList;

  const OrganizerStatsRow({super.key, required this.staffList});

  @override
  Widget build(BuildContext context) {
    final stats = StaffUtils.getStaffStats(staffList);

    return Row(
      children: [
        OrganizerStatCard(
          label: 'New',
          count: stats.newStaff,
          color: AppConstants.successColor,
        ),
        const SizedBox(width: 12),
        OrganizerStatCard(
          label: 'Active',
          count: stats.activeStaff,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 12),
        OrganizerStatCard(
          label: 'Departments',
          count: stats.departments,
          color: AppConstants.secondaryColor,
        ),
      ],
    );
  }
}

class OrganizerStatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const OrganizerStatCard({
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
