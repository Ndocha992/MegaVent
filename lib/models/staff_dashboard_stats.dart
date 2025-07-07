class StaffDashboardStats {
  final int totalEvents;
  final int totalConfirmed;
  final int upcomingEvents;
  final DateTime lastUpdated;

  StaffDashboardStats({
    required this.totalEvents,
    required this.totalConfirmed,
    required this.upcomingEvents,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory StaffDashboardStats.fromMap(Map<String, dynamic> map) {
    return StaffDashboardStats(
      totalEvents: map['totalEvents'] ?? 0,
      totalConfirmed: map['totalConfirmed'] ?? 0,
      upcomingEvents: map['upcomingEvents'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalEvents': totalEvents,
      'totalConfirmed': totalConfirmed,
      'upcomingEvents': upcomingEvents,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}