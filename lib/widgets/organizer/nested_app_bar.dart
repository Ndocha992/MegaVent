import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class NestedScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String screenTitle;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const NestedScreenAppBar({
    super.key,
    required this.screenTitle,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80, // Increased from default 56
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
      // Custom title with styled back button and screen name
      title: Row(
        children: [
          // Styled Back Button - Increased size
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22, // Increased from 18
              ),
              padding: EdgeInsets.zero,
              splashRadius: 25,
            ),
          ),
          const SizedBox(width: 20), // Increased spacing
          Expanded(
            child: Text(
              screenTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22, // Increased from 18
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      // Actions on the right side with better styling
      actions:
          actions?.map((action) {
            if (action is IconButton) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: (action).onPressed,
                  icon: action.icon,
                  padding: const EdgeInsets.all(12),
                  splashRadius: 24,
                ),
              );
            }
            return action;
          }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // Increased from kToolbarHeight (56)
}
