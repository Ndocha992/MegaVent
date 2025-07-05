import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AttendeesSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final String selectedEvent;
  final int filteredAttendeesCount;
  final VoidCallback onFilterPressed;
  final VoidCallback onEventCleared;

  const AttendeesSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedEvent,
    required this.filteredAttendeesCount,
    required this.onFilterPressed,
    required this.onEventCleared,
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
                child: AttendeesSearchField(
                  controller: searchController,
                  searchQuery: searchQuery,
                  onChanged: onSearchChanged,
                  onClear: onClearSearch,
                ),
              ),
              const SizedBox(width: 12),
              AttendeesFilterButton(onPressed: onFilterPressed),
            ],
          ),
          if (selectedEvent != 'All') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (selectedEvent != 'All')
                  AttendeesFilterChip(
                    label: 'Event: $selectedEvent',
                    onClear: onEventCleared,
                  ),
                const Spacer(),
                Text(
                  '$filteredAttendeesCount results',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AttendeesSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const AttendeesSearchField({
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
          hintText: 'Search attendees...',
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

class AttendeesFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AttendeesFilterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.filter_list, color: AppConstants.primaryColor),
        onPressed: onPressed,
      ),
    );
  }
}

class AttendeesFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const AttendeesFilterChip({
    super.key,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
