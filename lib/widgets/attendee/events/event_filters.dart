import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeEventFilters extends StatefulWidget {
  final String selectedCategory;
  final String selectedAvailability;
  final String selectedDateRange;
  final String selectedLocation;
  final List<String> categories;
  final Function(String, String, String, String) onFiltersChanged;

  const AttendeeEventFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedAvailability,
    required this.selectedDateRange,
    required this.selectedLocation,
    required this.categories,
    required this.onFiltersChanged,
  });

  @override
  State<AttendeeEventFilters> createState() => _AttendeeEventFiltersState();
}

class _AttendeeEventFiltersState extends State<AttendeeEventFilters> {
  late String _selectedCategory;
  late String _selectedAvailability;
  late String _selectedDateRange;
  late String _selectedLocation;

  final List<String> _availabilityOptions = [
    'All',
    'Available Spots',
    'Limited Spots',
    'Almost Full',
    'Full',
  ];

  final List<String> _dateRangeOptions = [
    'All Time',
    'Today',
    'This Week',
    'This Month',
    'Next Month',
    'Custom Range',
  ];

  final List<String> _locationOptions = [
    'All Locations',
    'Nairobi',
    'Mombasa',
    'Kisumu',
    'Nakuru',
    'Eldoret',
    'Online Events',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedAvailability = widget.selectedAvailability;
    _selectedDateRange = widget.selectedDateRange;
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: _buildHeader(),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryFilter(),
              const SizedBox(height: 24),
              _buildAvailabilityFilter(),
              const SizedBox(height: 24),
              _buildDateRangeFilter(),
              const SizedBox(height: 24),
              _buildLocationFilter(),
            ],
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppConstants.primaryGradient),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Filter Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Event Category', Icons.category),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              widget.categories.map((category) {
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
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? categoryColor.withOpacity(0.15)
                              : AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? categoryColor
                                : AppConstants.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 16,
                          color:
                              isSelected
                                  ? categoryColor
                                  : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            category,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? categoryColor
                                      : AppConstants.textSecondaryColor,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Availability', Icons.people_outline),
        const SizedBox(height: 12),
        _buildChipFilter(
          _availabilityOptions,
          _selectedAvailability,
          (value) => setState(() => _selectedAvailability = value),
          AppConstants.successColor,
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Date Range', Icons.date_range),
        const SizedBox(height: 12),
        _buildChipFilter(
          _dateRangeOptions,
          _selectedDateRange,
          (value) => setState(() => _selectedDateRange = value),
          AppConstants.primaryColor,
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location', Icons.location_on),
        const SizedBox(height: 12),
        _buildChipFilter(
          _locationOptions,
          _selectedLocation,
          (value) => setState(() => _selectedLocation = value),
          AppConstants.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppConstants.titleMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChipFilter(
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
    Color color,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((option) {
            final isSelected = selectedValue == option;

            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? color.withOpacity(0.1)
                          : AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : AppConstants.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? color : AppConstants.textSecondaryColor,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  List<Widget> _buildActions() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppConstants.borderColor),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedAvailability = 'All';
      _selectedDateRange = 'All Time';
      _selectedLocation = 'All Locations';
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _selectedCategory,
      _selectedAvailability,
      _selectedDateRange,
      _selectedLocation,
    );
    Navigator.pop(context);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return AppConstants.textSecondaryColor;

      // Business & Professional
      case 'technology':
        return const Color(0xFF2196F3); // Blue
      case 'business':
        return const Color(0xFF4CAF50); // Green
      case 'conference':
        return const Color(0xFF9C27B0); // Purple
      case 'seminar':
        return const Color(0xFF795548); // Brown
      case 'workshop':
        return const Color(0xFFFF9800); // Orange
      case 'networking':
        return const Color(0xFF607D8B); // Blue Grey
      case 'trade show':
        return const Color(0xFF00BCD4); // Cyan
      case 'expo':
        return const Color(0xFF3F51B5); // Indigo

      // Entertainment & Arts
      case 'music':
        return const Color(0xFFE91E63); // Pink
      case 'arts & culture':
        return const Color(0xFF9C27B0); // Purple
      case 'theater & performing arts':
        return const Color(0xFF673AB7); // Deep Purple
      case 'comedy shows':
        return const Color(0xFFFFC107); // Amber
      case 'film & cinema':
        return const Color(0xFF424242); // Grey
      case 'fashion':
        return const Color(0xFFE91E63); // Pink
      case 'entertainment':
        return const Color(0xFFFF5722); // Deep Orange

      // Community & Cultural
      case 'cultural festival':
        return const Color(0xFF8BC34A); // Light Green
      case 'community event':
        return const Color(0xFF4CAF50); // Green
      case 'religious event':
        return const Color(0xFF795548); // Brown
      case 'traditional ceremony':
        return const Color(0xFF607D8B); // Blue Grey
      case 'charity & fundraising':
        return const Color(0xFF4CAF50); // Green
      case 'cultural exhibition':
        return const Color(0xFF9C27B0); // Purple

      // Sports & Recreation
      case 'sports & recreation':
        return const Color(0xFF2196F3); // Blue
      case 'football (soccer)':
        return const Color(0xFF4CAF50); // Green
      case 'rugby':
        return const Color(0xFF795548); // Brown
      case 'athletics':
        return const Color(0xFFFF9800); // Orange
      case 'marathon & running':
        return const Color(0xFFF44336); // Red
      case 'outdoor adventure':
        return const Color(0xFF8BC34A); // Light Green
      case 'safari rally':
        return const Color(0xFF795548); // Brown
      case 'water sports':
        return const Color(0xFF2196F3); // Blue

      // Education & Development
      case 'education':
        return const Color(0xFF3F51B5); // Indigo
      case 'training & development':
        return const Color(0xFF009688); // Teal
      case 'youth programs':
        return const Color(0xFFFF9800); // Orange
      case 'academic conference':
        return const Color(0xFF673AB7); // Deep Purple
      case 'skill development':
        return const Color(0xFF00BCD4); // Cyan

      // Health & Wellness
      case 'health & wellness':
        return const Color(0xFF4CAF50); // Green
      case 'medical conference':
        return const Color(0xFFF44336); // Red
      case 'fitness & yoga':
        return const Color(0xFF8BC34A); // Light Green
      case 'mental health':
        return const Color(0xFF9C27B0); // Purple

      // Food & Agriculture
      case 'food & drink':
        return const Color(0xFFFF9800); // Orange
      case 'agricultural show':
        return const Color(0xFF8BC34A); // Light Green
      case 'food festival':
        return const Color(0xFFFF5722); // Deep Orange
      case 'cooking workshop':
        return const Color(0xFFFFC107); // Amber
      case 'wine tasting':
        return const Color(0xFF9C27B0); // Purple

      // Travel & Tourism
      case 'travel':
        return const Color(0xFF2196F3); // Blue
      case 'tourism promotion':
        return const Color(0xFF00BCD4); // Cyan
      case 'adventure tourism':
        return const Color(0xFF4CAF50); // Green
      case 'wildlife conservation':
        return const Color(0xFF8BC34A); // Light Green

      // Government & Politics
      case 'government event':
        return const Color(0xFF3F51B5); // Indigo
      case 'political rally':
        return const Color(0xFFF44336); // Red
      case 'public forum':
        return const Color(0xFF607D8B); // Blue Grey
      case 'civic engagement':
        return const Color(0xFF009688); // Teal

      // Special Occasions
      case 'wedding':
        return const Color(0xFFE91E63); // Pink
      case 'birthday party':
        return const Color(0xFFFFC107); // Amber
      case 'anniversary':
        return const Color(0xFF9C27B0); // Purple
      case 'graduation':
        return const Color(0xFF3F51B5); // Indigo
      case 'baby shower':
        return const Color(0xFFFFEB3B); // Yellow
      case 'corporate party':
        return const Color(0xFF607D8B); // Blue Grey

      // Seasonal & Holiday
      case 'christmas event':
        return const Color(0xFFF44336); // Red
      case 'new year celebration':
        return const Color(0xFFFFC107); // Amber
      case 'independence day':
        return const Color(0xFF4CAF50); // Green
      case 'eid celebration':
        return const Color(0xFF9C27B0); // Purple
      case 'diwali':
        return const Color(0xFFFF9800); // Orange
      case 'easter event':
        return const Color(0xFF8BC34A); // Light Green

      // Markets & Shopping
      case 'market event':
        return const Color(0xFF795548); // Brown
      case 'craft fair':
        return const Color(0xFFFF9800); // Orange
      case 'farmers market':
        return const Color(0xFF8BC34A); // Light Green
      case 'pop-up shop':
        return const Color(0xFFE91E63); // Pink

      // Other
      case 'other':
        return AppConstants.textSecondaryColor;

      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.all_inclusive;

      // Business & Professional
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      case 'conference':
        return Icons.groups;
      case 'seminar':
        return Icons.school;
      case 'workshop':
        return Icons.build;
      case 'networking':
        return Icons.people_outline;
      case 'trade show':
        return Icons.store;
      case 'expo':
        return Icons.business_center;

      // Entertainment & Arts
      case 'music':
        return Icons.music_note;
      case 'arts & culture':
        return Icons.palette;
      case 'theater & performing arts':
        return Icons.theater_comedy;
      case 'comedy shows':
        return Icons.sentiment_very_satisfied;
      case 'film & cinema':
        return Icons.movie;
      case 'fashion':
        return Icons.style;
      case 'entertainment':
        return Icons.celebration;

      // Community & Cultural
      case 'cultural festival':
        return Icons.festival;
      case 'community event':
        return Icons.people;
      case 'religious event':
        return Icons.place;
      case 'traditional ceremony':
        return Icons.castle;
      case 'charity & fundraising':
        return Icons.volunteer_activism;
      case 'cultural exhibition':
        return Icons.museum;

      // Sports & Recreation
      case 'sports & recreation':
        return Icons.sports;
      case 'football (soccer)':
        return Icons.sports_soccer;
      case 'rugby':
        return Icons.sports_rugby;
      case 'athletics':
        return Icons.directions_run;
      case 'marathon & running':
        return Icons.directions_run;
      case 'outdoor adventure':
        return Icons.terrain;
      case 'safari rally':
        return Icons.directions_car;
      case 'water sports':
        return Icons.pool;

      // Education & Development
      case 'education':
        return Icons.school;
      case 'training & development':
        return Icons.psychology;
      case 'youth programs':
        return Icons.groups;
      case 'academic conference':
        return Icons.library_books;
      case 'skill development':
        return Icons.trending_up;

      // Health & Wellness
      case 'health & wellness':
        return Icons.health_and_safety;
      case 'medical conference':
        return Icons.medical_services;
      case 'fitness & yoga':
        return Icons.fitness_center;
      case 'mental health':
        return Icons.psychology;

      // Food & Agriculture
      case 'food & drink':
        return Icons.restaurant;
      case 'agricultural show':
        return Icons.agriculture;
      case 'food festival':
        return Icons.fastfood;
      case 'cooking workshop':
        return Icons.kitchen;
      case 'wine tasting':
        return Icons.wine_bar;

      // Travel & Tourism
      case 'travel':
        return Icons.travel_explore;
      case 'tourism promotion':
        return Icons.map;
      case 'adventure tourism':
        return Icons.hiking;
      case 'wildlife conservation':
        return Icons.pets;

      // Government & Politics
      case 'government event':
        return Icons.account_balance;
      case 'political rally':
        return Icons.campaign;
      case 'public forum':
        return Icons.forum;
      case 'civic engagement':
        return Icons.how_to_vote;

      // Special Occasions
      case 'wedding':
        return Icons.favorite;
      case 'birthday party':
        return Icons.cake;
      case 'anniversary':
        return Icons.card_giftcard;
      case 'graduation':
        return Icons.school;
      case 'baby shower':
        return Icons.child_care;
      case 'corporate party':
        return Icons.business_center;

      // Seasonal & Holiday
      case 'christmas event':
        return Icons.celebration;
      case 'new year celebration':
        return Icons.star;
      case 'independence day':
        return Icons.flag;
      case 'eid celebration':
        return Icons.celebration;
      case 'diwali':
        return Icons.brightness_7;
      case 'easter event':
        return Icons.celebration;

      // Markets & Shopping
      case 'market event':
        return Icons.shopping_bag;
      case 'craft fair':
        return Icons.handyman;
      case 'farmers market':
        return Icons.storefront;
      case 'pop-up shop':
        return Icons.store;

      // Other
      case 'other':
        return Icons.event;

      default:
        return Icons.event;
    }
  }
}
