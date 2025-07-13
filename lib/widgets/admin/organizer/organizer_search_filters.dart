import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerSearchFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;

  const OrganizerSearchFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OrganizerSearchField(
                  controller: searchController,
                  searchQuery: searchQuery,
                  onChanged: onSearchChanged,
                  onClear: onClearSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrganizerSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const OrganizerSearchField({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search organizers...',
          prefixIcon: Icon(
            Icons.search,
            color: AppConstants.textSecondaryColor,
          ),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
