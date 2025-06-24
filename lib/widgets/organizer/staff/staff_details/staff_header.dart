import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class StaffHeaderWidget extends StatelessWidget {
  final Staff staff;

  const StaffHeaderWidget({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildProfileImage(),
          ),
          const SizedBox(height: 16),

          // Staff Name
          Text(
            staff.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Role
          Text(
            staff.role,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          // New Badge
          if (staff.isNew) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.successColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    // Check if profileImage exists and is not empty
    if (staff.profileImage != null && staff.profileImage!.isNotEmpty) {
      try {
        // Try to decode base64 image
        final imageBytes = base64Decode(staff.profileImage!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(58),
          child: Image.memory(
            imageBytes,
            width: 116,
            height: 116,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If base64 decoding fails, show initials
              return _buildInitialsAvatar();
            },
          ),
        );
      } catch (e) {
        // If base64 decoding fails, show initials
        return _buildInitialsAvatar();
      }
    } else {
      // If no profile image, show initials
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 58,
      backgroundColor: Colors.white,
      child: Text(
        _getInitials(staff.name),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final nameParts = name.trim().split(' ');
    final initials = nameParts
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join('');
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }
}