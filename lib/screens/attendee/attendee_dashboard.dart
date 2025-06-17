import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:provider/provider.dart';

class AttendeeDashboard extends StatelessWidget {
  const AttendeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppConstants.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'MegaVent',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppConstants.gradientContainerDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: AppConstants.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to create amazing events?',
                          style: AppConstants.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.celebration, color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Events',
                    '12',
                    Icons.event,
                    AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Attendees',
                    '248',
                    Icons.people,
                    AppConstants.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text('Quick Actions', style: AppConstants.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    'Create Event',
                    Icons.add_circle_outline,
                    AppConstants.primaryColor,
                  ),
                  _buildActionCard(
                    'View Events',
                    Icons.event_note,
                    AppConstants.secondaryColor,
                  ),
                  _buildActionCard(
                    'Analytics',
                    Icons.analytics,
                    AppConstants.accentColor,
                  ),
                  _buildActionCard(
                    'Settings',
                    Icons.settings,
                    AppConstants.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await authService.signOut();

    // Close loading dialog
    Navigator.of(context).pop();

    if (result['success']) {
      // Navigate to login screen or wherever you want after logout
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppConstants.headlineLarge.copyWith(color: color)),
          Text(title, style: AppConstants.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      decoration: AppConstants.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppConstants.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
