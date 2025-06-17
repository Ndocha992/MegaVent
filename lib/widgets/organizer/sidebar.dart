import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:provider/provider.dart';

class OrganizerSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const OrganizerSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header - Removed fixed height container to prevent overflow
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppConstants.primaryGradient,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Added this to prevent overflow
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

            // Menu Items - Wrapped in Flexible instead of Expanded to prevent overflow
            Flexible(
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

                    // Logout - Updated to use AuthService
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return ListTile(
                              leading:
                                  authService.isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppConstants.errorColor,
                                              ),
                                        ),
                                      )
                                      : const Icon(
                                        Icons.logout,
                                        color: AppConstants.errorColor,
                                      ),
                              title: Text(
                                authService.isLoading
                                    ? 'Logging out...'
                                    : 'Log Out',
                                style: const TextStyle(
                                  color: AppConstants.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap:
                                  authService.isLoading
                                      ? null
                                      : () {
                                        _showLogoutDialog(context, authService);
                                      },
                            );
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
          onTap: () => onNavigate(route),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during logout
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<AuthService>(
              builder: (context, authService, child) {
                return ElevatedButton(
                  onPressed:
                      authService.isLoading
                          ? null
                          : () async {
                            try {
                              final result = await authService.signOut();

                              if (result['success']) {
                                // Close dialog
                                Navigator.of(dialogContext).pop();

                                // Navigate to login screen
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              } else {
                                // Close dialog first
                                Navigator.of(dialogContext).pop();

                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ?? 'Logout failed',
                                    ),
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Close dialog
                              Navigator.of(dialogContext).pop();

                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Logout failed: ${e.toString()}',
                                  ),
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
                          : const Text('Log Out'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
