import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppConstants.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      title: Flexible(
        child: Row(
          children: [
            // App Logo - Responsive size
            Container(
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
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
                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: isSmallScreen ? 32 : 40,
                    height: isSmallScreen ? 32 : 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 16),
            // Flexible title that can shrink
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Additional actions if any
        if (actions != null) ...actions!,
        // Hamburger menu with responsive sizing
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onMenuPressed,
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            splashRadius: isSmallScreen ? 20 : 24,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}