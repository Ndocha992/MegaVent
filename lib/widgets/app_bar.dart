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
    final isVerySmallScreen = screenWidth < 350;

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
      title: Row(
        children: [
          // App Logo - More responsive sizing
          Container(
            width: isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50),
            height: isVerySmallScreen ? 35 : (isSmallScreen ? 40 : 50),
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
                borderRadius: BorderRadius.circular(
                  isVerySmallScreen ? 17.5 : (isSmallScreen ? 20 : 25),
                ),
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 40),
                  height: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 40),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 16)),
          // Use Expanded instead of Flexible for better text handling
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 24),
                fontWeight: FontWeight.bold,
                letterSpacing: isVerySmallScreen ? 0.3 : 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: [
        // Additional actions if any - make them responsive too
        if (actions != null)
          ...actions!.map((action) {
            if (action is IconButton) {
              return Container(
                margin: EdgeInsets.only(right: isVerySmallScreen ? 4 : 8),
                child: IconButton(
                  onPressed: action.onPressed,
                  icon: action.icon,
                  padding: EdgeInsets.all(
                    isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                  ),
                  splashRadius:
                      isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
                ),
              );
            }
            return action;
          }),
        // Hamburger menu with responsive sizing
        Container(
          margin: EdgeInsets.only(right: isVerySmallScreen ? 4 : 8),
          child: IconButton(
            onPressed: onMenuPressed,
            icon: Icon(
              Icons.menu,
              color: Colors.white,
              size: isVerySmallScreen ? 22 : (isSmallScreen ? 24 : 28),
            ),
            padding: EdgeInsets.all(
              isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
            ),
            splashRadius: isVerySmallScreen ? 18 : (isSmallScreen ? 20 : 24),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
