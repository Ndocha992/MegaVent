import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-staff';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: OrganizerAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Staff Management', style: AppConstants.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage your event staff and team members',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            // Add your staff content here
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppConstants.cardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text('Staff Screen Content', style: AppConstants.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'This is where your staff management features will be implemented.',
                    style: AppConstants.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
