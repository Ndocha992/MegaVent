import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class StaffEventHeader extends StatelessWidget {
  final Event event;

  const StaffEventHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image with Loading and Error States
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                // Background Image or Default Icon
                Positioned.fill(
                  child:
                      (event.posterUrl.isNotEmpty)
                          ? Image.network(
                            event.posterUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildLoadingState();
                            },
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildDefaultBackground(),
                          )
                          : _buildDefaultBackground(),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Event Category Badge
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Status Badge
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Event Title and Date
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateRange(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.3),
            AppConstants.secondaryColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: SpinKitThreeBounce(color: Colors.white, size: 30.0),
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor(event.category).withOpacity(0.8),
            _getCategoryColor(event.category).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(event.category),
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  // Updated _getCategoryColor method for both EventCard and EventHeader
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

  Color _getStatusColor() {
    final now = DateTime.now();
    if (event.startDate.isAfter(now)) {
      return AppConstants.primaryColor;
    } else if (event.endDate.isBefore(now)) {
      return AppConstants.textSecondaryColor;
    } else {
      return AppConstants.successColor;
    }
  }

  String _getStatusText() {
    final now = DateTime.now();
    if (event.startDate.isAfter(now)) {
      return 'UPCOMING';
    } else if (event.endDate.isBefore(now)) {
      return 'COMPLETED';
    } else {
      return 'ONGOING';
    }
  }

  String _formatDateRange() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (event.startDate.day == event.endDate.day &&
        event.startDate.month == event.endDate.month &&
        event.startDate.year == event.endDate.year) {
      return '${event.startDate.day} ${months[event.startDate.month - 1]} ${event.startDate.year}';
    } else {
      return '${event.startDate.day} ${months[event.startDate.month - 1]} - ${event.endDate.day} ${months[event.endDate.month - 1]} ${event.endDate.year}';
    }
  }
}
