import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';

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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return AppConstants.primaryColor;
      case 'business':
        return AppConstants.secondaryColor;
      case 'entertainment':
        return AppConstants.accentColor;
      case 'sports':
        return AppConstants.successColor;
      case 'education':
        return AppConstants.warningColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      case 'entertainment':
        return Icons.celebration;
      case 'sports':
        return Icons.sports;
      case 'education':
        return Icons.school;
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
