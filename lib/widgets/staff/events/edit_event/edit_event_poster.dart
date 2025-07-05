import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/edit_event/section_container.dart';
import 'package:megavent/services/cloudinary.dart';

class EditEventPoster extends StatefulWidget {
  final String? initialPosterUrl;
  final String eventId;
  final String? eventName;
  final ValueChanged<String?> onPosterUrlChanged;

  const EditEventPoster({
    super.key,
    this.initialPosterUrl,
    required this.eventId,
    this.eventName,
    required this.onPosterUrlChanged,
  });

  @override
  State<EditEventPoster> createState() => _EditEventPosterState();
}

class _EditEventPosterState extends State<EditEventPoster> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        print('Starting image upload for event: ${widget.eventId}');

        // Upload to Cloudinary using the same method as create event
        final String? cloudinaryUrl = await Cloudinary.uploadEventBanner(
          File(image.path),
          eventId: widget.eventId,
          eventName: widget.eventName ?? 'event',
        );

        if (cloudinaryUrl != null) {
          print('Upload successful, new URL: $cloudinaryUrl');

          // Notify parent about the change immediately
          widget.onPosterUrlChanged(cloudinaryUrl);
          print('Parent notified with new URL: $cloudinaryUrl');

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Event poster updated successfully!'),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          print('Upload failed - cloudinaryUrl is null');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Failed to upload image. Please try again.',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removePoster() {
    print('Removing poster, current URL: ${widget.initialPosterUrl}');
    // Notify parent about the removal
    widget.onPosterUrlChanged(null);
    print('Parent notified - poster removed');
  }

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Event Poster',
      icon: Icons.image_outlined,
      children: [
        _buildImageUploadArea(),
        const SizedBox(height: 12),
        _buildPosterPreview(),
      ],
    );
  }

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppConstants.primaryColor.withOpacity(0.05),
        ),
        child:
            _isUploading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: SpinKitThreeBounce(
                        color: AppConstants.primaryColor,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Updating poster...',
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: AppConstants.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.initialPosterUrl != null &&
                              widget.initialPosterUrl!.isNotEmpty
                          ? 'Change Event Poster'
                          : 'Upload Event Poster',
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPosterPreview() {
    final currentUrl = widget.initialPosterUrl;

    if (currentUrl != null && currentUrl.isNotEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConstants.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                currentUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SpinKitThreeBounce(
                      color: AppConstants.primaryColor,
                      size: 20.0,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Container(
                    color: AppConstants.backgroundColor,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removePoster,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.borderColor,
            style: BorderStyle.solid,
          ),
          color: AppConstants.backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'No poster uploaded',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Upload Event Poster" to add an image',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
  }
}
