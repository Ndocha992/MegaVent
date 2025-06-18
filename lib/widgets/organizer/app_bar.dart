import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const OrganizerAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100, // Increased from default 56
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppConstants.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      // Remove automatic leading widget
      automaticallyImplyLeading: false,
      // Custom title with logo and app name on the left
      title: Row(
        children: [
          // App Logo - Increased size
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24, // Increased from 20
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      // Move hamburger menu to actions (right side)
      actions: [
        // Hamburger menu with better styling
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28, // Increased icon size
            ),
            padding: const EdgeInsets.all(12),
            splashRadius: 24,
          ),
        ),
        // Include any additional actions passed to the widget
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100); // Increased from kToolbarHeight (56)
}