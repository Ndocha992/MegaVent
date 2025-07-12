class TimeUtils {
  /// Formats a DateTime to a relative time string (e.g., "2 hours ago", "Just now")
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
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  /// Formats a DateTime to a simple date string (e.g., "12/07/2025")
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formats a DateTime to a detailed date string (e.g., "July 12, 2025")
  static String formatDateDetailed(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Formats a DateTime to include time (e.g., "12/07/2025 14:30")
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Checks if a DateTime is recent (within the last 6 hours)
  static bool isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 6;
  }

  /// Checks if a DateTime is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// Checks if a DateTime is this week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inDays < 7;
  }

  /// Gets the duration between two dates in a human-readable format
  static String getDurationBetween(DateTime start, DateTime end) {
    final difference = end.difference(start);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Less than a minute';
    }
  }

  /// Formats time for display (e.g., "14:30", "2:30 PM")
  static String formatTime(DateTime dateTime, {bool use24Hour = true}) {
    if (use24Hour) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      int hour = dateTime.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour > 12 ? hour - 12 : hour;
      hour = hour == 0 ? 12 : hour;
      return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
    }
  }
}