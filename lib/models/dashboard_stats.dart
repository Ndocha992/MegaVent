import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardStats {
  final int totalEvents;
  final int totalAttendees;
  final int totalStaff;
  final int activeEvents;
  final int upcomingEvents;
  final int completedEvents;
  final DateTime lastUpdated;

  DashboardStats({
    required this.totalEvents,
    required this.totalAttendees,
    required this.totalStaff,
    required this.activeEvents,
    required this.upcomingEvents,
    required this.completedEvents,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'totalEvents': totalEvents,
      'totalAttendees': totalAttendees,
      'totalStaff': totalStaff,
      'activeEvents': activeEvents,
      'upcomingEvents': upcomingEvents,
      'completedEvents': completedEvents,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Create from Firestore DocumentSnapshot
  factory DashboardStats.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return DashboardStats(
      totalEvents: data['totalEvents'] ?? 0,
      totalAttendees: data['totalAttendees'] ?? 0,
      totalStaff: data['totalStaff'] ?? 0,
      activeEvents: data['activeEvents'] ?? 0,
      upcomingEvents: data['upcomingEvents'] ?? 0,
      completedEvents: data['completedEvents'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map (for your existing code)
  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalEvents: map['totalEvents'] ?? 0,
      totalAttendees: map['totalAttendees'] ?? 0,
      totalStaff: map['totalStaff'] ?? 0,
      activeEvents: map['activeEvents'] ?? 0,
      upcomingEvents: map['upcomingEvents'] ?? 0,
      completedEvents: map['completedEvents'] ?? 0,
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : map['lastUpdated'] is DateTime
              ? map['lastUpdated']
              : DateTime.now(),
    );
  }

  // Create from JSON (useful for API responses)
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEvents: json['totalEvents'] ?? 0,
      totalAttendees: json['totalAttendees'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      activeEvents: json['activeEvents'] ?? 0,
      upcomingEvents: json['upcomingEvents'] ?? 0,
      completedEvents: json['completedEvents'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'totalAttendees': totalAttendees,
      'totalStaff': totalStaff,
      'activeEvents': activeEvents,
      'upcomingEvents': upcomingEvents,
      'completedEvents': completedEvents,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // CopyWith method for easy updates
  DashboardStats copyWith({
    int? totalEvents,
    int? totalAttendees,
    int? totalStaff,
    int? activeEvents,
    int? upcomingEvents,
    int? completedEvents,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      totalEvents: totalEvents ?? this.totalEvents,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      totalStaff: totalStaff ?? this.totalStaff,
      activeEvents: activeEvents ?? this.activeEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      completedEvents: completedEvents ?? this.completedEvents,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods for calculations
  double get eventCompletionRate {
    if (totalEvents == 0) return 0.0;
    return (completedEvents / totalEvents) * 100;
  }

  double get averageAttendeesPerEvent {
    if (totalEvents == 0) return 0.0;
    return totalAttendees / totalEvents;
  }

  int get inactiveEvents => totalEvents - activeEvents;

  // Helper method to check if stats are recent (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    return lastUpdated.isAfter(oneHourAgo);
  }

  // Factory method to create empty stats
  factory DashboardStats.empty() {
    return DashboardStats(
      totalEvents: 0,
      totalAttendees: 0,
      totalStaff: 0,
      activeEvents: 0,
      upcomingEvents: 0,
      completedEvents: 0,
    );
  }

  @override
  String toString() {
    return 'DashboardStats(totalEvents: $totalEvents, totalAttendees: $totalAttendees, totalStaff: $totalStaff, activeEvents: $activeEvents, upcomingEvents: $upcomingEvents, completedEvents: $completedEvents)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardStats &&
        other.totalEvents == totalEvents &&
        other.totalAttendees == totalAttendees &&
        other.totalStaff == totalStaff &&
        other.activeEvents == activeEvents &&
        other.upcomingEvents == upcomingEvents &&
        other.completedEvents == completedEvents;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalEvents,
      totalAttendees,
      totalStaff,
      activeEvents,
      upcomingEvents,
      completedEvents,
    );
  }
}