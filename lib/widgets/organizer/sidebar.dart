import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class CustomSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const CustomSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppConstants.primaryGradient,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: AppConstants.primaryColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MegaVent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Organizer Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    title: 'Dashboard',
                    route: '/dashboard',
                    isActive: currentRoute == '/dashboard',
                  ),
                  _buildMenuItem(
                    icon: Icons.event_outlined,
                    activeIcon: Icons.event,
                    title: 'Events',
                    route: '/events',
                    isActive: currentRoute == '/events',
                  ),
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    activeIcon: Icons.people,
                    title: 'Staff',
                    route: '/staff',
                    isActive: currentRoute == '/staff',
                  ),
                  _buildMenuItem(
                    icon: Icons.group_outlined,
                    activeIcon: Icons.group,
                    title: 'Attendees',
                    route: '/attendees',
                    isActive: currentRoute == '/attendees',
                  ),
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    title: 'Profile',
                    route: '/profile',
                    isActive: currentRoute == '/profile',
                  ),
                  const Spacer(),
                  
                  // Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppConstants.errorColor,
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppConstants.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppConstants.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: ListTile(
          leading: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.white : AppConstants.textSecondaryColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : AppConstants.textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          onTap: () => onNavigate(route),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout logic here
                onNavigate('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}