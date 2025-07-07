import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/models/organizer.dart';
import 'dart:convert';
import 'dart:typed_data';

class StaffProfileHeaderCard extends StatelessWidget {
  final Organizer organizer;

  const StaffProfileHeaderCard({
    super.key,
    required this.organizer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppConstants.cardDecoration.copyWith(
        gradient: const LinearGradient(
          colors: AppConstants.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Reduced padding
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90, // Slightly smaller
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing
            Text(
              organizer.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22, // Slightly smaller
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              organizer.jobTitle ?? 'Event Organizer',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: organizer.isApproved
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                organizer.approvalStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (organizer.profileImage != null && organizer.profileImage!.isNotEmpty) {
      // Check if it's a base64 image
      if (organizer.profileImage!.startsWith('data:image')) {
        try {
          // Extract base64 data from data URL
          String base64String = organizer.profileImage!.split(',')[1];
          Uint8List imageBytes = base64Decode(base64String);
          return Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          );
        } catch (e) {
          return _buildDefaultAvatar();
        }
      } else if (organizer.profileImage!.startsWith('http')) {
        // Network image
        return Image.network(
          organizer.profileImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else {
        // Assume it's just base64 without data URL prefix
        try {
          Uint8List imageBytes = base64Decode(organizer.profileImage!);
          return Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
          );
        } catch (e) {
          return _buildDefaultAvatar();
        }
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 45,
        color: Colors.white,
      ),
    );
  }
}