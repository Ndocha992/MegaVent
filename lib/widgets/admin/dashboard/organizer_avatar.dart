import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerAvatar extends StatelessWidget {
  final Organizer organizer;

  const OrganizerAvatar({super.key, required this.organizer});

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> parts = name.trim().split(' ');
    parts = parts.where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  bool _isBase64(String? value) {
    if (value == null || value.isEmpty) return false;
    try {
      base64Decode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = organizer.profileImage;
    final initials = _getInitials(organizer.fullName);

    if (profileImage != null &&
        profileImage.isNotEmpty &&
        _isBase64(profileImage)) {
      try {
        Uint8List bytes = base64Decode(profileImage);
        return ClipOval(
          child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
        );
      } catch (e) {
        return _buildInitialsAvatar(initials);
      }
    } else {
      return _buildInitialsAvatar(initials);
    }
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.8),
            AppConstants.primaryColor,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
