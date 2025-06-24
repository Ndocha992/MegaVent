import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class EventDescriptionSection extends StatefulWidget {
  final Event event;

  const EventDescriptionSection({super.key, required this.event});

  @override
  State<EventDescriptionSection> createState() =>
      _EventDescriptionSectionState();
}

class _EventDescriptionSectionState extends State<EventDescriptionSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Generate a sample description if not available
    String description = widget.event.description;
    bool isLongText = description.length > 200;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About This Event', style: AppConstants.titleLarge),
          const SizedBox(height: 16),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isLongText && !isExpanded
                  ? '${description.substring(0, 200)}...'
                  : description,
              style: AppConstants.bodyMedium.copyWith(height: 1.5),
            ),
          ),

          if (isLongText) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Show Less' : 'Read More',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppConstants.primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
