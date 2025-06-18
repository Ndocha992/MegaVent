import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-profile';

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
            Text('Profile Settings', style: AppConstants.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage your account and preferences',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            // Add your profile content here
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppConstants.cardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Screen Content',
                    style: AppConstants.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is where your profile management features will be implemented.',
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
