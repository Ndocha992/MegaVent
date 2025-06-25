import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';

class EventHeader extends StatelessWidget {
  final Event event;

  const EventHeader({super.key, required this.event});

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
      // Business & Professional
      case 'technology':
        return AppConstants.primaryColor;
      case 'business':
        return AppConstants.secondaryColor;
      case 'conference':
        return AppConstants.primaryDarkColor;
      case 'seminar':
        return AppConstants.primaryLightColor;
      case 'workshop':
        return AppConstants.accentColor;
      case 'networking':
        return AppConstants.secondaryDarkColor;
      case 'trade show':
      case 'expo':
        return AppConstants.successColor;

      // Entertainment & Arts
      case 'music':
        return AppConstants.accentColor;
      case 'arts & culture':
        return AppConstants.warningColor;
      case 'theater & performing arts':
        return AppConstants.primaryLightColor;
      case 'comedy shows':
        return AppConstants.successColor;
      case 'film & cinema':
        return AppConstants.primaryColor;
      case 'fashion':
        return AppConstants.secondaryColor;
      case 'entertainment':
        return AppConstants.accentColor;

      // Community & Cultural
      case 'cultural festival':
        return AppConstants.warningColor;
      case 'community event':
        return AppConstants.successColor;
      case 'religious event':
        return AppConstants.primaryDarkColor;
      case 'traditional ceremony':
        return AppConstants.secondaryDarkColor;
      case 'charity & fundraising':
        return AppConstants.accentColor;
      case 'cultural exhibition':
        return AppConstants.primaryLightColor;

      // Sports & Recreation
      case 'sports & recreation':
      case 'sports':
        return AppConstants.successColor;
      case 'football (soccer)':
        return AppConstants.accentColor;
      case 'rugby':
        return AppConstants.primaryColor;
      case 'athletics':
        return AppConstants.successColor;
      case 'marathon & running':
        return AppConstants.secondaryColor;
      case 'outdoor adventure':
        return AppConstants.primaryLightColor;
      case 'safari rally':
        return AppConstants.warningColor;
      case 'water sports':
        return AppConstants.secondaryDarkColor;

      // Education & Development
      case 'education':
        return AppConstants.warningColor;
      case 'training & development':
        return AppConstants.primaryColor;
      case 'youth programs':
        return AppConstants.successColor;
      case 'academic conference':
        return AppConstants.primaryDarkColor;
      case 'skill development':
        return AppConstants.accentColor;

      // Health & Wellness
      case 'health & wellness':
        return AppConstants.successColor;
      case 'medical conference':
        return AppConstants.primaryColor;
      case 'fitness & yoga':
        return AppConstants.accentColor;
      case 'mental health':
        return AppConstants.secondaryColor;

      // Food & Agriculture
      case 'food & drink':
        return AppConstants.warningColor;
      case 'agricultural show':
        return AppConstants.successColor;
      case 'food festival':
        return AppConstants.accentColor;
      case 'cooking workshop':
        return AppConstants.secondaryColor;
      case 'wine tasting':
        return AppConstants.primaryLightColor;

      // Travel & Tourism
      case 'travel':
        return AppConstants.secondaryColor;
      case 'tourism promotion':
        return AppConstants.accentColor;
      case 'adventure tourism':
        return AppConstants.primaryLightColor;
      case 'wildlife conservation':
        return AppConstants.successColor;

      // Government & Politics
      case 'government event':
        return AppConstants.primaryDarkColor;
      case 'political rally':
        return AppConstants.primaryColor;
      case 'public forum':
        return AppConstants.secondaryDarkColor;
      case 'civic engagement':
        return AppConstants.accentColor;

      // Special Occasions
      case 'wedding':
        return AppConstants.primaryLightColor;
      case 'birthday party':
        return AppConstants.successColor;
      case 'anniversary':
        return AppConstants.accentColor;
      case 'graduation':
        return AppConstants.warningColor;
      case 'baby shower':
        return AppConstants.secondaryColor;
      case 'corporate party':
        return AppConstants.primaryColor;

      // Seasonal & Holiday
      case 'christmas event':
        return AppConstants.successColor;
      case 'new year celebration':
        return AppConstants.warningColor;
      case 'independence day':
        return AppConstants.primaryColor;
      case 'eid celebration':
        return AppConstants.accentColor;
      case 'diwali':
        return AppConstants.warningColor;
      case 'easter event':
        return AppConstants.primaryLightColor;

      // Markets & Shopping
      case 'market event':
        return AppConstants.successColor;
      case 'craft fair':
        return AppConstants.warningColor;
      case 'farmers market':
        return AppConstants.accentColor;
      case 'pop-up shop':
        return AppConstants.secondaryColor;

      // Other
      case 'other':
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
        return Icons.store;

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
        return Icons.checkroom;
      case 'entertainment':
        return Icons.celebration;

      // Community & Cultural
      case 'cultural festival':
        return Icons.festival;
      case 'community event':
        return Icons.groups;
      case 'religious event':
        return Icons.place;
      case 'traditional ceremony':
        return Icons.local_florist;
      case 'charity & fundraising':
        return Icons.volunteer_activism;
      case 'cultural exhibition':
        return Icons.museum;

      // Sports & Recreation
      case 'sports & recreation':
      case 'sports':
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
        return Icons.child_care;
      case 'academic conference':
        return Icons.menu_book;
      case 'skill development':
        return Icons.emoji_objects;

      // Health & Wellness
      case 'health & wellness':
        return Icons.health_and_safety;
      case 'medical conference':
        return Icons.medical_services;
      case 'fitness & yoga':
        return Icons.fitness_center;
      case 'mental health':
        return Icons.psychology_alt;

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
        return Icons.tour;
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
        return Icons.celebration;
      case 'graduation':
        return Icons.school;
      case 'baby shower':
        return Icons.child_friendly;
      case 'corporate party':
        return Icons.business_center;

      // Seasonal & Holiday
      case 'christmas event':
        return Icons.card_giftcard;
      case 'new year celebration':
        return Icons.celebration;
      case 'independence day':
        return Icons.flag;
      case 'eid celebration':
        return Icons.mosque;
      case 'diwali':
        return Icons.lightbulb;
      case 'easter event':
        return Icons.egg;

      // Markets & Shopping
      case 'market event':
        return Icons.store;
      case 'craft fair':
        return Icons.handyman;
      case 'farmers market':
        return Icons.local_grocery_store;
      case 'pop-up shop':
        return Icons.shopping_bag;

      // Other
      case 'other':
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
