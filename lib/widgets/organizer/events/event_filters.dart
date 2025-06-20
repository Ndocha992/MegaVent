import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class EventFilters extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const EventFilters({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<EventFilters> createState() => _EventFiltersState();
}

class _EventFiltersState extends State<EventFilters> {
  late String _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'All',
      'icon': Icons.all_inclusive,
      'color': AppConstants.textSecondaryColor,
    },
    {
      'name': 'Technology',
      'icon': Icons.computer,
      'color': AppConstants.primaryColor,
    },
    {
      'name': 'Business',
      'icon': Icons.business,
      'color': AppConstants.secondaryColor,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.celebration,
      'color': AppConstants.accentColor,
    },
    {
      'name': 'Sports',
      'icon': Icons.sports,
      'color': AppConstants.successColor,
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': AppConstants.warningColor,
    },
    {
      'name': 'Health',
      'icon': Icons.health_and_safety,
      'color': Colors.pink,
    },
    {
      'name': 'Arts',
      'icon': Icons.palette,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
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
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color'].withOpacity(0.15)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category['color']
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'],
                          size: 18,
                          color: isSelected
                              ? category['color']
                              : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
                          style: TextStyle(
                            color: isSelected
                                ? category['color']
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