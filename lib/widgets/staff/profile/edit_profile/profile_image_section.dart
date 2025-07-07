import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class StaffProfileImageSection extends StatelessWidget {
  final String? selectedImageBase64;
  final String fullName;
  final Function(String?) onImageChanged;

  const StaffProfileImageSection({
    super.key,
    required this.selectedImageBase64,
    required this.fullName,
    required this.onImageChanged,
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
    final initials = _getInitials(fullName.trim());
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
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.person, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildImageAvatar() {
    try {
      final imageBytes = base64Decode(selectedImageBase64!);
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
                  errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
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
      return _buildInitialsAvatar();
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      onImageChanged(base64Encode(bytes));
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      onImageChanged(base64Encode(bytes));
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppConstants.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Update Profile Photo',
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.photo_camera_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera(context);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery(context);
                  },
                ),
                if (selectedImageBase64 != null)
                  _buildImageOption(
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      onImageChanged(null);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppConstants.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              selectedImageBase64 != null
                  ? _buildImageAvatar()
                  : _buildInitialsAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(context),
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
                      selectedImageBase64 != null
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
            selectedImageBase64 != null
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