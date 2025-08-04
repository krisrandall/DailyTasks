class DateUtils {
  /// Check if two DateTime objects represent the same date (ignoring time)
  static bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDate(date, DateTime.now());
  }
  
  /// Check if a date was yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDate(date, yesterday);
  }
  
  /// Get the start of today (midnight)
  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Get the start of tomorrow (next midnight)
  static DateTime get startOfTomorrow {
    return startOfToday.add(const Duration(days: 1));
  }
  
  /// Calculate time until next midnight
  static Duration get timeUntilMidnight {
    return startOfTomorrow.difference(DateTime.now());
  }
  
  /// Check if we've crossed midnight since the last check
  static bool hasCrossedMidnight(DateTime? lastCheckTime) {
    if (lastCheckTime == null) return true;
    
    final now = DateTime.now();
    final lastCheck = lastCheckTime;
    
    // If the dates are different, we've crossed midnight
    return !isSameDate(now, lastCheck);
  }
  
  /// Format time remaining until midnight
  static String formatTimeUntilMidnight() {
    final duration = timeUntilMidnight;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m until reset';
    } else {
      return '${minutes}m until reset';
    }
  }
  
  /// Get a human-readable string for when a task was last completed
  static String getLastCompletedString(DateTime? lastCompleted) {
    if (lastCompleted == null) return 'Never completed';
    
    if (isToday(lastCompleted)) {
      return 'Completed today';
    } else if (isYesterday(lastCompleted)) {
      return 'Completed yesterday';
    } else {
      final daysAgo = DateTime.now().difference(lastCompleted).inDays;
      return 'Completed $daysAgo days ago';
    }
  }
}