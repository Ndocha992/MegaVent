import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:provider/provider.dart';

class OrganizerSidebar extends StatelessWidget {
  final String currentRoute;

  const OrganizerSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header - Extends to top of screen
          Container(
            height:
                MediaQuery.of(context).size.height *
                0.28, // Dynamic height based on screen
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppConstants.primaryGradient,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top +
                    20, // Dynamic top padding for safe area
                20,
                20,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Changed from start to center
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo with Gradient
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/logo.png',
                          width: 60,
                          height: 60,
                        ),
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
                      'Organizer',
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

          // Menu Items - Flexible container
          Expanded(
            child: Column(
              children: [
                // Menu items container - Takes available space
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.dashboard_outlined,
                          activeIcon: Icons.dashboard,
                          title: 'Dashboard',
                          route: '/organizer-dashboard',
                          isActive: currentRoute == '/organizer-dashboard',
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.event_outlined,
                          activeIcon: Icons.event,
                          title: 'Events',
                          route: '/organizer-events',
                          isActive: currentRoute == '/organizer-events',
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.people_outline,
                          activeIcon: Icons.people,
                          title: 'Staff',
                          route: '/organizer-staff',
                          isActive: currentRoute == '/organizer-staff',
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.group_outlined,
                          activeIcon: Icons.group,
                          title: 'Attendees',
                          route: '/organizer-attendees',
                          isActive: currentRoute == '/organizer-attendees',
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          title: 'Profile',
                          route: '/organizer-profile',
                          isActive: currentRoute == '/organizer-profile',
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout - Fixed at bottom with safe area padding
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    MediaQuery.of(context).padding.bottom +
                        20, // Dynamic bottom padding
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration:
            isActive
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
          onTap: () {
            // Close drawer first
            Navigator.of(context).pop();

            // Navigate with replacement instead of push
            if (route != currentRoute) {
              Navigator.of(context).pushReplacementNamed(route);
            }
          },
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
            Consumer<AuthService>(
              builder: (context, authService, child) {
                return ElevatedButton(
                  onPressed:
                      authService.isLoading
                          ? null
                          : () async {
                            // Show loading
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );

                            // Perform logout
                            final result = await authService.signOut();

                            // Close loading dialog
                            Navigator.of(context).pop();

                            // Close confirmation dialog
                            Navigator.of(context).pop();

                            if (result['success']) {
                              // Navigate to login screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: AppConstants.successColor,
                                ),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message']),
                                  backgroundColor: AppConstants.errorColor,
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                  ),
                  child:
                      authService.isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.white),
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
