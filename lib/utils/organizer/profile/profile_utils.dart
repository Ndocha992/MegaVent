import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileUtils {
  // Image configuration constants
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  /// Format large numbers with K, M suffixes
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format date to dd/mm/yyyy
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Check if string is a valid base64 image
  static bool isBase64Image(String? str) {
    if (str == null || str.isEmpty) return false;
    
    // Check for data URL format
    if (str.startsWith('data:image')) {
      return str.contains(',') && str.split(',').length == 2;
    }
    
    // Check for plain base64
    try {
      // Basic base64 validation
      final regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return regex.hasMatch(str) && str.length % 4 == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get base64 string from data URL or plain base64
  static String? getBase64FromString(String? str) {
    if (str == null || str.isEmpty) return null;
    
    if (str.startsWith('data:image')) {
      final parts = str.split(',');
      return parts.length == 2 ? parts[1] : null;
    }
    
    return str;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number (basic validation)
  static bool isValidPhone(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Check if it has at least 10 digits
    return cleanPhone.length >= 10;
  }

  // Validate URL format
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://') || url.contains('.');
    } catch (e) {
      return false;
    }
  }

  // Format URL to include protocol
  static String formatUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  // Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length >= 10) {
      // Format as (XXX) XXX-XXXX for US numbers
      if (cleanPhone.length == 10) {
        return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
      }
      // Format as +X (XXX) XXX-XXXX for international numbers
      else if (cleanPhone.length == 11 && cleanPhone.startsWith('1')) {
        return '+1 (${cleanPhone.substring(1, 4)}) ${cleanPhone.substring(4, 7)}-${cleanPhone.substring(7)}';
      }
    }
    
    return phone; // Return original if formatting fails
  }

  // Check and request permissions for camera/gallery
  static Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.photos,
    ].request();

    return permissions[Permission.camera] == PermissionStatus.granted ||
           permissions[Permission.photos] == PermissionStatus.granted;
  }

  // Show image source selection dialog
  static Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _pickImageFromSource(ImageSource.camera);
                  Navigator.pop(context, image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _pickImageFromSource(ImageSource.gallery);
                  Navigator.pop(context, image);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Pick image from specified source
  static Future<XFile?> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (image != null) {
        // Check file size
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > maxImageSizeInBytes) {
          throw Exception('Image size must be less than 5MB');
        }
      }

      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Validate profile completeness
  static Map<String, dynamic> validateProfileCompleteness(Map<String, dynamic> profileData) {
    int completedFields = 0;
    int totalFields = 11; // Total number of profile fields
    List<String> missingFields = [];

    // Required fields
    if (profileData['fullName']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Full Name');
    }

    if (profileData['email']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Email');
    }

    if (profileData['phone']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Phone');
    }

    // Optional fields
    if (profileData['organization']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Organization');
    }

    if (profileData['jobTitle']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Job Title');
    }

    if (profileData['bio']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Bio');
    }

    if (profileData['website']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Website');
    }

    if (profileData['address']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Address');
    }

    if (profileData['city']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('City');
    }

    if (profileData['country']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Country');
    }

    if (profileData['profileImage']?.toString().trim().isNotEmpty == true) {
      completedFields++;
    } else {
      missingFields.add('Profile Image');
    }

    double completionPercentage = (completedFields / totalFields) * 100;

    return {
      'completionPercentage': completionPercentage.round(),
      'completedFields': completedFields,
      'totalFields': totalFields,
      'missingFields': missingFields,
      'isComplete': completionPercentage >= 80, // Consider 80% as complete
    };
  }

  // Generate profile completion message
  static String getProfileCompletionMessage(Map<String, dynamic> completionData) {
    int percentage = completionData['completionPercentage'];
    
    if (percentage >= 90) {
      return 'Excellent! Your profile is almost complete.';
    } else if (percentage >= 70) {
      return 'Good progress! Consider adding more details.';
    } else if (percentage >= 50) {
      return 'You\'re halfway there! Keep going.';
    } else {
      return 'Let\'s build your profile to attract more attendees.';
    }
  }

  // Get profile strength color
  static Color getProfileStrengthColor(int percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Clean and validate input text
  static String cleanInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Check if string contains only letters and spaces
  static bool isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim());
  }

  // Generate initials from full name
  static String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '';
    
    List<String> nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    } else {
      return '${nameParts[0].substring(0, 1)}${nameParts[nameParts.length - 1].substring(0, 1)}'.toUpperCase();
    }
  }

  // Check if image file is valid
  static Future<bool> isValidImageFile(File file) async {
    try {
      // Check file size
      final fileSize = await file.length();
      if (fileSize > maxImageSizeInBytes) {
        return false;
      }

      // Check file extension
      final fileName = file.path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      
      return validExtensions.any((ext) => fileName.endsWith(ext));
    } catch (e) {
      return false;
    }
  }
}