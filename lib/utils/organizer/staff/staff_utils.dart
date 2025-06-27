import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class StaffUtils {
  /// Returns the color associated with a department
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'operations':
        return AppConstants.primaryColor;
      case 'creative':
        return AppConstants.secondaryColor;
      case 'it':
        return AppConstants.accentColor;
      case 'hr':
        return AppConstants.warningColor;
      case 'finance':
        return AppConstants.successColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  /// Formats hire date to a readable format
  static String formatHireDate(DateTime hiredAt) {
    final now = DateTime.now();
    final difference = now.difference(hiredAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${hiredAt.day}/${hiredAt.month}/${hiredAt.year}';
    }
  }

  /// Generates initials from a full name - Fixed to handle edge cases
  static String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return 'U'; // Return 'U' for Unknown if empty

    // Split by space and filter out empty strings
    final nameParts =
        fullName.trim().split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.isEmpty) return 'U'; // Fallback if no valid parts

    if (nameParts.length == 1) {
      // Single name, take first character
      return nameParts[0][0].toUpperCase();
    } else {
      // Multiple names, take first character of first and last names
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }
  }

  /// Filters staff list based on search query
  static List<Staff> filterStaffBySearch(
    List<Staff> staffList,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return staffList;

    return staffList
        .where(
          (member) =>
              member.fullName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              member.role.toLowerCase().contains(searchQuery.toLowerCase()) ||
              member.department.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              member.email.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  /// Filters staff list by department
  static List<Staff> filterStaffByDepartment(
    List<Staff> staffList,
    String department,
  ) {
    if (department == 'All') return staffList;
    return staffList
        .where((member) => member.department == department)
        .toList();
  }

  /// Filters staff list by tab index
  static List<Staff> filterStaffByTab(List<Staff> staffList, int tabIndex) {
    switch (tabIndex) {
      case 0: // All Staff
        return staffList;
      case 1: // New Staff
        return staffList.where((member) => member.isNew).toList();
      case 2: // Active Staff
        return staffList.where((member) => !member.isNew).toList();
      default:
        return staffList;
    }
  }

  /// Gets staff statistics
  static StaffStats getStaffStats(List<Staff> staffList) {
    final newStaffCount = staffList.where((member) => member.isNew).length;
    final activeStaffCount = staffList.where((member) => !member.isNew).length;
    final departmentCount =
        staffList.map((member) => member.department).toSet().length;

    return StaffStats(
      total: staffList.length,
      newStaff: newStaffCount,
      activeStaff: activeStaffCount,
      departments: departmentCount,
    );
  }

  /// Gets unique departments from staff list
  static List<String> getDepartments(List<Staff> staffList) {
    return staffList.map((member) => member.department).toSet().toList()
      ..sort();
  }
}

/// Data class for staff statistics
class StaffStats {
  final int total;
  final int newStaff;
  final int activeStaff;
  final int departments;

  const StaffStats({
    required this.total,
    required this.newStaff,
    required this.activeStaff,
    required this.departments,
  });
}
