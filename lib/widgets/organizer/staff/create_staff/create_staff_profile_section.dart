import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class CreateStaffProfileSection extends StatelessWidget {
  final String? profileImageBase64;
  final String staffName;
  final VoidCallback onImagePickerTap;

  const CreateStaffProfileSection({
    super.key,
    required this.profileImageBase64,
    required this.staffName,
    required this.onImagePickerTap,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final nameParts = name.trim().split(' ');
    final initials = nameParts
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join('');
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(staffName);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child:
            initials.isNotEmpty
                ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.person_add, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildImageAvatar() {
    try {
      final imageBytes = base64Decode(profileImageBase64!);
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildInitialsAvatar(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      // If base64 decoding fails, show initials avatar
      return _buildInitialsAvatar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              profileImageBase64 != null
                  ? _buildImageAvatar()
                  : _buildInitialsAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onImagePickerTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.secondaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      profileImageBase64 != null
                          ? Icons.edit_outlined
                          : Icons.photo_camera_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profileImageBase64 != null
                ? 'Tap to change photo'
                : 'Add Profile Photo',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional but recommended',
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
