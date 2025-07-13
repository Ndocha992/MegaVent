import 'package:megavent/models/organizer.dart';

class OrganizerUtils {
  static OrganizerStats getOrganizerStats(List<Organizer> organizers) {
    int newOrganizers = 0;
    int activeOrganizers = 0;
    int pendingOrganizers = 0;
    Set<String> uniqueCategories = {};

    for (final organizer in organizers) {
      // Count new organizers
      if (_isRecentlyRegistered(organizer.createdAt)) {
        newOrganizers++;
      }

      // Count by status - FIXED: Use boolean directly instead of toLowerCase()
      if (organizer.isApproved) {
        activeOrganizers++;
      } else {
        pendingOrganizers++;
      }
    }

    return OrganizerStats(
      newOrganizers: newOrganizers,
      activeOrganizers: activeOrganizers,
      pendingOrganizers: pendingOrganizers,
      categories: uniqueCategories.length,
    );
  }

  static bool _isRecentlyRegistered(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <=
        7; // Consider organizers registered within 7 days as "new"
  }

  static String getOrganizerStatusDisplay(bool isApproved) {
    return isApproved ? 'Approved' : 'Pending';
  }

  static List<String> getEventCategories() {
    return [
      // Business & Professional
      'Technology',
      'Business',
      'Conference',
      'Seminar',
      'Workshop',
      'Networking',
      'Trade Show',
      'Expo',

      // Entertainment & Arts
      'Music',
      'Arts & Culture',
      'Theater & Performing Arts',
      'Comedy Shows',
      'Film & Cinema',
      'Fashion',
      'Entertainment',

      // Community & Cultural
      'Cultural Festival',
      'Community Event',
      'Religious Event',
      'Traditional Ceremony',
      'Charity & Fundraising',
      'Cultural Exhibition',

      // Sports & Recreation
      'Sports & Recreation',
      'Football (Soccer)',
      'Rugby',
      'Athletics',
      'Marathon & Running',
      'Outdoor Adventure',
      'Safari Rally',
      'Water Sports',

      // Education & Development
      'Education',
      'Training & Development',
      'Youth Programs',
      'Academic Conference',
      'Skill Development',

      // Health & Wellness
      'Health & Wellness',
      'Medical Conference',
      'Fitness & Yoga',
      'Mental Health',

      // Food & Agriculture
      'Food & Drink',
      'Agricultural Show',
      'Food Festival',
      'Cooking Workshop',
      'Wine Tasting',

      // Travel & Tourism
      'Travel',
      'Tourism Promotion',
      'Adventure Tourism',
      'Wildlife Conservation',

      // Government & Politics
      'Government Event',
      'Political Rally',
      'Public Forum',
      'Civic Engagement',

      // Special Occasions
      'Wedding',
      'Birthday Party',
      'Anniversary',
      'Graduation',
      'Baby Shower',
      'Corporate Party',

      // Seasonal & Holiday
      'Christmas Event',
      'New Year Celebration',
      'Independence Day',
      'Eid Celebration',
      'Diwali',
      'Easter Event',

      // Markets & Shopping
      'Market Event',
      'Craft Fair',
      'Farmers Market',
      'Pop-up Shop',

      // Other
      'Other',
    ];
  }

  static String formatRegistrationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return 'Just now';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static List<Organizer> sortOrganizers(
    List<Organizer> organizers,
    OrganizerSortType sortType,
  ) {
    final List<Organizer> sortedList = List.from(organizers);

    switch (sortType) {
      case OrganizerSortType.nameAsc:
        sortedList.sort(
          (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
        break;
      case OrganizerSortType.nameDesc:
        sortedList.sort(
          (a, b) =>
              b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
        );
        break;
      case OrganizerSortType.dateAsc:
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case OrganizerSortType.dateDesc:
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case OrganizerSortType.statusAsc:
        // FIXED: Custom comparator for boolean values
        sortedList.sort((a, b) {
          if (a.isApproved == b.isApproved) return 0;
          return a.isApproved
              ? 1
              : -1; // false (pending) first, then true (approved)
        });
        break;
      case OrganizerSortType.statusDesc:
        // FIXED: Custom comparator for boolean values
        sortedList.sort((a, b) {
          if (a.isApproved == b.isApproved) return 0;
          return a.isApproved
              ? -1
              : 1; // true (approved) first, then false (pending)
        });
        break;
      case OrganizerSortType.companyAsc:
        sortedList.sort(
          (a, b) => (a.organization ?? '').toLowerCase().compareTo(
            (b.organization ?? '').toLowerCase(),
          ),
        );
        break;
      case OrganizerSortType.companyDesc:
        sortedList.sort(
          (a, b) => (b.organization ?? '').toLowerCase().compareTo(
            (a.organization ?? '').toLowerCase(),
          ),
        );
        break;
    }

    return sortedList;
  }

  static List<Organizer> filterOrganizers(
    List<Organizer> organizers, {
    String? searchQuery,
    String? category,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    List<Organizer> filteredList = List.from(organizers);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchLower = searchQuery.toLowerCase();
      filteredList =
          filteredList.where((organizer) {
            return organizer.fullName.toLowerCase().contains(searchLower) ||
                organizer.email.toLowerCase().contains(searchLower) ||
                (organizer.organization ?? '').toLowerCase().contains(
                  searchLower,
                ) ||
                organizer.phone.toLowerCase().contains(searchLower);
          }).toList();
    }

    // Apply status filter - FIXED: Compare with boolean values correctly
    if (status != null && status != 'All') {
      filteredList =
          filteredList.where((organizer) {
            if (status.toLowerCase() == 'approved') {
              return organizer.isApproved == true;
            } else if (status.toLowerCase() == 'pending') {
              return organizer.isApproved == false;
            }
            return true; // Default case
          }).toList();
    }

    // Apply date range filter
    if (dateFrom != null) {
      filteredList =
          filteredList.where((organizer) {
            return organizer.createdAt.isAfter(dateFrom) ||
                organizer.createdAt.isAtSameMomentAs(dateFrom);
          }).toList();
    }

    if (dateTo != null) {
      filteredList =
          filteredList.where((organizer) {
            return organizer.createdAt.isBefore(dateTo) ||
                organizer.createdAt.isAtSameMomentAs(dateTo);
          }).toList();
    }

    return filteredList;
  }
}

class OrganizerStats {
  final int newOrganizers;
  final int activeOrganizers;
  final int pendingOrganizers;
  final int categories;

  OrganizerStats({
    required this.newOrganizers,
    required this.activeOrganizers,
    required this.pendingOrganizers,
    required this.categories,
  });
}

enum OrganizerSortType {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  statusAsc,
  statusDesc,
  companyAsc,
  companyDesc,
}
