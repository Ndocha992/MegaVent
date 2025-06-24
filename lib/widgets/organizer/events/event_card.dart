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