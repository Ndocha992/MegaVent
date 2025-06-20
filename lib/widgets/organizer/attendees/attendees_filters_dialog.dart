import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

class AttendeesFiltersDialog extends StatefulWidget {
  final String selectedEvent;
  final String selectedStatus;
  final Function(String) onEventChanged;
  final Function(String) onStatusChanged;

  const AttendeesFiltersDialog({
    super.key,
    required this.selectedEvent,
    required this.selectedStatus,
    required this.onEventChanged,
    required this.onStatusChanged,
  });

  @override
  State<AttendeesFiltersDialog> createState() => _AttendeesFiltersDialogState();
}

class _AttendeesFiltersDialogState extends State<AttendeesFiltersDialog> {
  late String _selectedEvent;
  late String _selectedStatus;

  final List<Map<String, dynamic>> _statuses = [
    {
      'name': 'All',
      'icon': Icons.all_inclusive,
      'color': AppConstants.textSecondaryColor,
    },
    {
      'name': 'Registered',
      'icon': Icons.person_add,
      'color': AppConstants.primaryColor,
    },
    {
      'name': 'Attended',
      'icon': Icons.check_circle,
      'color': AppConstants.successColor,
    },
    {'name': 'No Show', 'icon': Icons.cancel, 'color': AppConstants.errorColor},
  ];

  List<Map<String, dynamic>> get _events {
    List<Map<String, dynamic>> eventsList = [
      {
        'name': 'All',
        'icon': Icons.all_inclusive,
        'color': AppConstants.textSecondaryColor,
      },
    ];

    // Get unique events from fake data
    final uniqueEvents =
        FakeData.events
            .map(
              (event) => {
                'name': event.name,
                'icon': Icons.event,
                'color': AppConstants.primaryColor,
              },
            )
            .toList();

    eventsList.addAll(uniqueEvents);
    return eventsList;
  }

  @override
  void initState() {
    super.initState();
    _selectedEvent = widget.selectedEvent;
    _selectedStatus = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.filter_list, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          const Text('Filter Attendees'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _events.map((event) {
                    final isSelected = _selectedEvent == event['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEvent = event['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? event['color'].withOpacity(0.15)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? event['color']
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              event['icon'],
                              size: 16,
                              color:
                                  isSelected
                                      ? event['color']
                                      : AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event['name'],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? event['color']
                                        : AppConstants.textSecondaryColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Status',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _statuses.map((status) {
                    final isSelected = _selectedStatus == status['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = status['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? status['color'].withOpacity(0.15)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? status['color']
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status['icon'],
                              size: 16,
                              color:
                                  isSelected
                                      ? status['color']
                                      : AppConstants.textSecondaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status['name'],
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? status['color']
                                        : AppConstants.textSecondaryColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                fontSize: 12,
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
            widget.onEventChanged(_selectedEvent);
            widget.onStatusChanged(_selectedStatus);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}
