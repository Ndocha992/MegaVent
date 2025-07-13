import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerTabBar extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const OrganizerTabBar({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        onTap: onTabChanged,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
        ],
      ),
    );
  }
}