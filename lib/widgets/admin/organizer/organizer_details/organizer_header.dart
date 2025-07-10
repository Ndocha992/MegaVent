import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerHeaderWidget extends StatefulWidget {
  final Staff staff;

  const OrganizerHeaderWidget({super.key, required this.staff});

  @override
  State<OrganizerHeaderWidget> createState() => _OrganizerHeaderWidgetState();
}

class _OrganizerHeaderWidgetState extends State<OrganizerHeaderWidget> {
  bool _isNetworkImageLoading = false;
  bool _hasImageError = false;
  ImageProvider? _backgroundImageProvider;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  void _loadBackgroundImage() {
    final profileImage = widget.staff.profileImage;
    if (profileImage != null && profileImage.isNotEmpty) {
      try {
        if (_isBase64(profileImage)) {
          _backgroundImageProvider = MemoryImage(base64Decode(profileImage));
        } else {
          _backgroundImageProvider = NetworkImage(profileImage);
        }
      } catch (e) {
        _backgroundImageProvider = null;
      }
    }
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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 280,
        maxHeight: 320, // Allow some flexibility for content
      ),
      child: Stack(
        children: [
          // Blurred background image
          if (_backgroundImageProvider != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _backgroundImageProvider!,
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      if (mounted) {
                        setState(() {
                          _backgroundImageProvider = null;
                        });
                      }
                    },
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Fallback gradient background
          if (_backgroundImageProvider == null)
            Positioned.fill(
              child: Container(
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
              ),
            ),

          // Content with SafeArea and proper spacing
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child:
                          _isNetworkImageLoading
                              ? _buildLoadingIndicator()
                              : _buildProfileImage(),
                    ),
                    const SizedBox(height: 16),

                    // Staff Name
                    Flexible(
                      child: Text(
                        widget.staff.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Role
                    Flexible(
                      child: Text(
                        widget.staff.role,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // New Badge
                    if (widget.staff.isNew) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(58),
      ),
      child: const Center(
        child: SpinKitThreeBounce(color: Colors.white, size: 20.0),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImage = widget.staff.profileImage;

    if (profileImage != null && profileImage.isNotEmpty && !_hasImageError) {
      if (_isBase64(profileImage)) {
        // Base64 images load instantly, no loading builder needed
        return ClipRRect(
          borderRadius: BorderRadius.circular(58),
          child: Image.memory(
            base64Decode(profileImage),
            width: 116,
            height: 116,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasImageError = true;
                  });
                }
              });
              return _buildInitialsAvatar();
            },
          ),
        );
      } else {
        // Network images need loading builder
        return ClipRRect(
          borderRadius: BorderRadius.circular(58),
          child: Image.network(
            profileImage,
            width: 116,
            height: 116,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isNetworkImageLoading = false;
                    });
                  }
                });
                return child;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isNetworkImageLoading = true;
                  });
                }
              });
              return _buildLoadingIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasImageError = true;
                    _isNetworkImageLoading = false;
                  });
                }
              });
              return _buildInitialsAvatar();
            },
          ),
        );
      }
    } else {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 58,
      backgroundColor: Colors.white,
      child: Text(
        _getInitials(widget.staff.name),
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
