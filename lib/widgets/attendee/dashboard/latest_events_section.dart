import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/screens/attendee/events_details.dart';

class LatestEventsSection extends StatelessWidget {
  final List<Event> allLatestEvents;
  final VoidCallback onViewAll;

  const LatestEventsSection({
    super.key,
    required this.allLatestEvents,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with better spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Events',
                style: AppConstants.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppConstants.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Events list with improved layout
        allLatestEvents.isEmpty
            ? _buildEmptyEventsState()
            : SizedBox(
              height: 260, // Increased height for better content fit
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                scrollDirection: Axis.horizontal,
                itemCount: allLatestEvents.take(5).length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final event = allLatestEvents[index];
                  return _buildEventCard(context, event);
                },
              ),
            ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () => _navigateToEventDetails(context, event),
      child: Container(
        width: 280, // Optimized width
        decoration: AppConstants.cardDecoration,
        child: Column(
          children: [
            // Image section with fixed height
            Container(
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildEventImage(event),
              ),
            ),
            // Content section with controlled height
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event name with proper text handling
                    Text(
                      event.name,
                      style: AppConstants.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Location with better layout
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.textSecondaryColor,
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date with better formatting
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatEventDate(event.startDate),
                            style: AppConstants.bodySmall.copyWith(
                              color: AppConstants.textSecondaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(Event event) {
    if (event.posterUrl.isNotEmpty) {
      return Stack(
        children: [
          // Background gradient fallback
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppConstants.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Network image with improved error handling
          Image.network(
            event.posterUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImageFallback();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppConstants.primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else {
      return _buildImageFallback();
    }
  }

  Widget _buildImageFallback() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppConstants.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
          ),
          // Center icon with better styling
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0 && difference.inDays <= 7) {
      return '${difference.inDays} days away';
    } else if (difference.inDays < 0 && difference.inDays >= -7) {
      return '${difference.inDays.abs()} days ago';
    } else {
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
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }

  Widget _buildEmptyEventsState() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(32),
      decoration: AppConstants.cardDecoration,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 40,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Events Available',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for exciting events\nin your area',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetails(BuildContext context, Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttendeeEventsDetails(event: event),
      ),
    );
  }
}
