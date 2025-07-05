import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/event.dart'; // Changed from fake_data import

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final bool isCompact;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppConstants.cardDecoration.copyWith(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildEventHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventTitle(),
                  if (!isCompact) ...[
                    const SizedBox(height: 12),
                    _buildEventDetails(),
                    const SizedBox(height: 16),
                    _buildEventStats(),
                  ] else ...[
                    const SizedBox(height: 8),
                    _buildCompactEventInfo(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Stack(
      children: [
        Container(
          height: isCompact ? 100 : 150,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor.withOpacity(0.8),
                AppConstants.secondaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child:
                      (event.posterUrl.isNotEmpty)
                          ? Image.network(
                            event.posterUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.1,
                                ),
                                child: const Center(
                                  child: SpinKitThreeBounce(
                                    color: AppConstants.primaryColor,
                                    size: 20.0,
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildDefaultEventIcon(),
                          )
                          : _buildDefaultEventIcon(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor(event.category).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (event.isNew)
          Positioned(
            top: isCompact ? 8 : 12,
            right: isCompact ? 8 : 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.successColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (!isCompact)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.startDate.day.toString(),
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getMonthName(event.startDate.month),
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultEventIcon() {
    return Container(
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          _getCategoryIcon(event.category),
          size: isCompact ? 30 : 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEventTitle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style:
                    isCompact
                        ? AppConstants.titleMedium
                        : AppConstants.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isCompact) ...[
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactEventInfo() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              event.category,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.people,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${event.registeredCount}/${event.capacity}',
              style: AppConstants.bodySmall,
            ),
            const Spacer(),
            Icon(
              Icons.location_on,
              size: 16,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                event.location,
                style: AppConstants.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Column(
      children: [
        _buildDetailRow(
          Icons.calendar_today,
          '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          Icons.access_time,
          '${event.startTime} - ${event.endTime}',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(Icons.location_on, event.location),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventStats() {
    final registrationProgress =
        event.capacity > 0 ? event.registeredCount / event.capacity : 0.0;
    final attendanceProgress =
        event.registeredCount > 0
            ? event.attendedCount / event.registeredCount
            : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Registered',
            '${event.registeredCount}/${event.capacity}',
            registrationProgress,
            AppConstants.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Attended',
            '${event.attendedCount}/${event.registeredCount}',
            attendanceProgress,
            AppConstants.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3,
          ),
        ],
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

  String _getMonthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]}';
  }
}
