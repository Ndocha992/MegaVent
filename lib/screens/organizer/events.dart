import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-events';

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
            Text('Events Management', style: AppConstants.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Manage and organize your events',
              style: AppConstants.bodyLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            // Add your events content here
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppConstants.cardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 64,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text('Events Screen Content', style: AppConstants.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'This is where your events management features will be implemented.',
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
