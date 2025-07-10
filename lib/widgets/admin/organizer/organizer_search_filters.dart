import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerSearchFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedDepartment;
  final int filteredStaffCount;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterPressed;
  final VoidCallback onDepartmentCleared;

  const OrganizerSearchFilters({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedDepartment,
    required this.filteredStaffCount,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterPressed,
    required this.onDepartmentCleared,
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
              const SizedBox(width: 12),
              OrganizerFilterButton(onPressed: onFilterPressed),
            ],
          ),
          if (selectedDepartment != 'All') ...[
            const SizedBox(height: 12),
            OrganizerFilterChip(
              department: selectedDepartment,
              resultCount: filteredStaffCount,
              onClear: onDepartmentCleared,
            ),
          ],
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
          hintText: 'Search organizer...',
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

class OrganizerFilterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OrganizerFilterButton({super.key, required this.onPressed});

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

class OrganizerFilterChip extends StatelessWidget {
  final String department;
  final int resultCount;
  final VoidCallback onClear;

  const OrganizerFilterChip({
    super.key,
    required this.department,
    required this.resultCount,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                department,
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
        ),
        const Spacer(),
        Text(
          '$resultCount results',
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
