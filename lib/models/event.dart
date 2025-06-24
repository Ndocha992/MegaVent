import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String category;
  final String posterUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String location;
  final int capacity;
  final int registeredCount;
  final int attendedCount;
  final String organizerId;
  final String? organizerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.posterUrl,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.capacity,
    this.registeredCount = 0,
    this.attendedCount = 0,
    required this.organizerId,
    this.organizerName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'posterUrl': posterUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'attendedCount': attendedCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Firestore DocumentSnapshot
  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Event(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      location: data['location'] ?? '',
      capacity: data['capacity'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
      attendedCount: data['attendedCount'] ?? 0,
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      startDate: map['startDate'] is Timestamp
          ? (map['startDate'] as Timestamp).toDate()
          : map['startDate'] is DateTime
              ? map['startDate']
              : DateTime.now(),
      endDate: map['endDate'] is Timestamp
          ? (map['endDate'] as Timestamp).toDate()
          : map['endDate'] is DateTime
              ? map['endDate']
              : DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 0,
      registeredCount: map['registeredCount'] ?? 0,
      attendedCount: map['attendedCount'] ?? 0,
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] is DateTime
              ? map['updatedAt']
              : DateTime.now(),
    );
  }

  // Create from JSON (useful for API responses)
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      capacity: json['capacity'] ?? 0,
      registeredCount: json['registeredCount'] ?? 0,
      attendedCount: json['attendedCount'] ?? 0,
      organizerId: json['organizerId'] ?? '',
      organizerName: json['organizerName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'posterUrl': posterUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'capacity': capacity,
      'registeredCount': registeredCount,
      'attendedCount': attendedCount,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method for easy updates
  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? posterUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? location,
    int? capacity,
    int? registeredCount,
    int? attendedCount,
    String? organizerId,
    String? organizerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      posterUrl: posterUrl ?? this.posterUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      attendedCount: attendedCount ?? this.attendedCount,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  
  bool get isCompleted => endDate.isBefore(DateTime.now());
  
  bool get hasAvailableSpots => registeredCount < capacity;
  
  int get availableSpots => capacity - registeredCount;
  
  double get attendanceRate =>
      registeredCount > 0 ? (attendedCount / registeredCount) * 100 : 0.0;

  // Calculate if event is "new" (created within the last 30 minutes)
  bool get isNew {
    final now = DateTime.now();
    final thirtyMinutesAgo = now.subtract(const Duration(minutes: 30));
    return createdAt.isAfter(thirtyMinutesAgo);
  }

  String get status {
    if (isCompleted) return 'Completed';
    if (isOngoing) return 'Ongoing';
    if (isUpcoming) return 'Upcoming';
    return 'Draft';
  }

  String get eventDateRange {
    if (startDate.day == endDate.day &&
        startDate.month == endDate.month &&
        startDate.year == endDate.year) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  String get eventTimeRange => '$startTime - $endTime';

  @override
  String toString() {
    return 'Event(id: $id, name: $name, category: $category, startDate: $startDate, location: $location, capacity: $capacity, registeredCount: $registeredCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}