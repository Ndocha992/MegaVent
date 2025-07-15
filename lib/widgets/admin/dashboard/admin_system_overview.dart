import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class AdminSystemOverview extends StatelessWidget {
  final List<Organizer> organizers;
  final List<Event> events;
  final List<Staff> staff;
  final List<Attendee> attendees;
  final List<Registration> registrations;

  const AdminSystemOverview({
    super.key,
    required this.organizers,
    required this.events,
    required this.staff,
    required this.attendees,
    required this.registrations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Overview', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.4, // Reduced from 1.8 to make cards taller
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Organizers',
              organizers.length,
              Icons.business,
              AppConstants.primaryColor,
            ),
            _buildStatCard(
              'Events',
              events.length,
              Icons.event,
              AppConstants.secondaryColor,
            ),
            _buildStatCard(
              'Staff',
              staff.length,
              Icons.people,
              AppConstants.accentColor,
            ),
            _buildStatCard(
              'Attendees',
              attendees.length,
              Icons.person,
              AppConstants.successColor,
            ),
            _buildStatCard(
              'Registrations',
              registrations.length,
              Icons.how_to_reg,
              AppConstants.warningColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      decoration: AppConstants.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12), // Increased spacing
          Text(
            value.toString(),
            style: AppConstants.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8), // Increased spacing
          Flexible(
            // Added to prevent overflow
            child: Text(
              title,
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Handle long text gracefully
            ),
          ),
        ],
      ),
    );
  }
}
