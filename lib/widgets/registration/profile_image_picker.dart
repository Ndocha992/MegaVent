import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? profileImageBase64;
  final VoidCallback onImagePicked;

  const ProfileImagePicker({
    super.key,
    required this.profileImageBase64,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onImagePicked,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: profileImageBase64 != null
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFE2E8F0),
                      ],
                    ),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: profileImageBase64 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.memory(
                      base64Decode(profileImageBase64!),
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 50,
                        color: AppConstants.textSecondaryColor.withOpacity(0.5),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppConstants.primaryGradient,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profileImageBase64 != null ? 'Tap to change photo' : 'Add profile photo',
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
    );
  }
}