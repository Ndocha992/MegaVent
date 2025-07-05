import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AttendeesTabBar extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const AttendeesTabBar({
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
        isScrollable: true,
        tabs: const [
          Tab(text: 'All Attendees'),
          Tab(text: 'Attended'),
          Tab(text: 'No Show'),
        ],
      ),
    );
  }
}