import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/create_event/section_container.dart';

class CategorySection extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories; // Added this parameter
  final Function(String) onCategoryChanged;

  const CategorySection({
    super.key,
    required this.selectedCategory,
    required this.categories, // Added this parameter
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Category',
      icon: Icons.category_outlined,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppConstants.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Select Category',
            ),
            items:
                categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
