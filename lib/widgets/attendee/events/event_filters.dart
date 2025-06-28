import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeEventFilters extends StatefulWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String) onCategoryChanged;

  const AttendeeEventFilters({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  State<AttendeeEventFilters> createState() => _AttendeeEventFiltersState();
}

class _AttendeeEventFiltersState extends State<AttendeeEventFilters> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.all_inclusive;
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      case 'entertainment':
        return Icons.celebration;
      case 'sports':
        return Icons.sports;
      case 'education':
        return Icons.school;
      case 'health':
        return Icons.health_and_safety;
      case 'arts':
        return Icons.palette;
      default:
        return Icons.category;
    }
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return AppConstants.textSecondaryColor;
      case 'technology':
        return AppConstants.primaryColor;
      case 'business':
        return AppConstants.secondaryColor;
      case 'entertainment':
        return AppConstants.accentColor;
      case 'sports':
        return AppConstants.successColor;
      case 'education':
        return AppConstants.warningColor;
      case 'health':
        return Colors.pink;
      case 'arts':
        return Colors.purple;
      default:
        return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          const Text('Filter Events'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.categories.map((category) {
                final isSelected = _selectedCategory == category;
                final categoryColor = _getCategoryColor(category);
                final categoryIcon = _getCategoryIcon(category);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? categoryColor.withOpacity(0.15)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? categoryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 18,
                          color: isSelected
                              ? categoryColor
                              : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? categoryColor
                                : AppConstants.textSecondaryColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCategoryChanged(_selectedCategory);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}