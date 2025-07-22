import 'package:flutter/material.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class EventHelpers {
  // Helper to get event start DateTime
  static DateTime getEventStartDateTime(Event event) {
    try {
      final startTimeParts = event.startTime.split(':');
      if (startTimeParts.length < 2) {
        throw FormatException('Invalid time format: ${event.startTime}');
      }

      final startHour = int.parse(startTimeParts[0]);
      final minuteAndPeriod = startTimeParts[1].trim();

      // Extract minute and AM/PM
      final minuteMatch = RegExp(r'(\d+)').firstMatch(minuteAndPeriod);
      final startMinute =
          minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

      final isPM = minuteAndPeriod.toUpperCase().contains('PM');
      final isAM = minuteAndPeriod.toUpperCase().contains('AM');

      int hour24 = startHour;
      if (isPM && startHour != 12) {
        hour24 = startHour + 12;
      } else if (isAM && startHour == 12) {
        hour24 = 0;
      }

      final startDateTime = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
        hour24,
        startMinute,
      );

      return startDateTime;
    } catch (e) {
      debugPrint('Error parsing event start time: $e');
      // Return event start date with default time if parsing fails
      return DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
        9, // Default to 9 AM
        0,
      );
    }
  }

  // Helper method for event end time
  static DateTime getEventEndDateTime(Event event) {
    try {
      final endTimeParts = event.endTime.split(':');
      if (endTimeParts.length < 2) {
        throw FormatException('Invalid time format: ${event.endTime}');
      }

      final endHour = int.parse(endTimeParts[0]);
      final minuteAndPeriod = endTimeParts[1].trim();

      // Extract minute and AM/PM
      final minuteMatch = RegExp(r'(\d+)').firstMatch(minuteAndPeriod);
      final endMinute =
          minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

      final isPM = minuteAndPeriod.toUpperCase().contains('PM');
      final isAM = minuteAndPeriod.toUpperCase().contains('AM');

      int hour24 = endHour;
      if (isPM && endHour != 12) {
        hour24 = endHour + 12;
      } else if (isAM && endHour == 12) {
        hour24 = 0;
      }

      final endDateTime = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
        hour24,
        endMinute,
      );

      return endDateTime;
    } catch (e) {
      debugPrint('Error parsing event end time: $e');
      // Return event end date with default time if parsing fails
      return DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
        17, // Default to 5 PM
        0,
      );
    }
  }

  // Helper method to check if event has ended
  static bool isEventEnded(Event event) {
    final endDateTime = getEventEndDateTime(event);
    final hasEnded = endDateTime.isBefore(DateTime.now());
    return hasEnded;
  }

  // Helper method to check if event is upcoming
  static bool isEventUpcoming(Event event) {
    final now = DateTime.now();
    final eventStart = getEventStartDateTime(event);
    final eventEnd = getEventEndDateTime(event);

    // Event is upcoming if start time is in the future
    // (end time should also be in future, but start time is the key criteria)
    final isUpcoming = eventStart.isAfter(now);

    return isUpcoming;
  }

  // Helper method to get event status information
  static Map<String, dynamic> getEventStatus(
    Event event,
    Registration registration,
  ) {
    final now = DateTime.now();
    final eventStart = getEventStartDateTime(event);
    final eventEnd = getEventEndDateTime(event);

    // Improved event status determination with debugging
    String statusText;
    Color statusColor;
    bool isUpcoming = false;
    bool hasEnded = false;
    bool isOngoing = false;

    if (registration.attended) {
      statusText = 'Attended';
      statusColor = AppConstants.successColor;
    } else if (eventEnd.isBefore(now)) {
      // Event has completely ended
      statusText = 'Ended';
      statusColor = AppConstants.errorColor;
      hasEnded = true;
    } else if (eventStart.isAfter(now)) {
      // Event hasn't started yet
      statusText = 'Upcoming';
      statusColor = AppConstants.accentColor;
      isUpcoming = true;
    } else if (eventStart.isBefore(now) && eventEnd.isAfter(now)) {
      // Event is currently happening
      statusText = 'Ongoing';
      statusColor = AppConstants.primaryColor;
      isOngoing = true;
    } else {
      // Fallback
      statusText = 'Registered';
      statusColor = AppConstants.primaryColor;
    }

    return {
      'statusText': statusText,
      'statusColor': statusColor,
      'isUpcoming': isUpcoming,
      'hasEnded': hasEnded,
      'isOngoing': isOngoing,
    };
  }

  // Helper method to get month name
  static String getMonthName(int month) {
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

  // Helper method to get time ago string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  // Helper method to check if a date is recent
  static bool isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 6;
  }
}
