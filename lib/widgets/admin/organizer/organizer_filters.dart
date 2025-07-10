import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerFilters extends StatefulWidget {
  final String selectedDepartment;
  final Function(String) onDepartmentChanged;

  const OrganizerFilters({
    super.key,
    required this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  State<OrganizerFilters> createState() => _OrganizerFiltersState();
}

class _OrganizerFiltersState extends State<OrganizerFilters> {
  late String _selectedDepartment;

  final List<Map<String, dynamic>> _departments = [
    {
      'name': 'All',
      'icon': Icons.all_inclusive,
      'color': AppConstants.textSecondaryColor,
    },
    {
      'name': 'Operations',
      'icon': Icons.settings,
      'color': AppConstants.primaryColor,
    },
    {
      'name': 'Creative',
      'icon': Icons.palette,
      'color': AppConstants.secondaryColor,
    },
    {
      'name': 'IT',
      'icon': Icons.computer,
      'color': AppConstants.accentColor,
    },
    {
      'name': 'HR',
      'icon': Icons.people,
      'color': AppConstants.warningColor,
    },
    {
      'name': 'Finance',
      'icon': Icons.account_balance,
      'color': AppConstants.successColor,
    },
    {
      'name': 'Marketing',
      'icon': Icons.campaign,
      'color': Colors.pink,
    },
    {
      'name': 'Security',
      'icon': Icons.security,
      'color': Colors.deepOrange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDepartment = widget.selectedDepartment;
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
          const Text('Filter Organizer'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _departments.map((department) {
                final isSelected = _selectedDepartment == department['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDepartment = department['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? department['color'].withOpacity(0.15)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? department['color']
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          department['icon'],
                          size: 18,
                          color: isSelected
                              ? department['color']
                              : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          department['name'],
                          style: TextStyle(
                            color: isSelected
                                ? department['color']
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
            widget.onDepartmentChanged(_selectedDepartment);
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