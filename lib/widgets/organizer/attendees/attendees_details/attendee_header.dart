import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/models/registration.dart';
import 'package:megavent/utils/constants.dart';

class AttendeeHeaderWidget extends StatefulWidget {
  final Attendee attendee;
  final Registration? registration;
  final String eventName;

  const AttendeeHeaderWidget({
    super.key,
    required this.attendee,
    this.registration,
    required this.eventName,
  });

  @override
  State<AttendeeHeaderWidget> createState() => _AttendeeHeaderWidgetState();
}

class _AttendeeHeaderWidgetState extends State<AttendeeHeaderWidget> {
  bool _hasImageError = false;
  ImageProvider? _backgroundImageProvider;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  void _loadBackgroundImage() {
    final profileImage = widget.attendee.profileImage;
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

  // Getters that use registration data when available
  bool get hasAttended {
    return widget.registration?.hasAttended ?? false;
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

  Widget _buildAttendeeAvatar() {
    // Handle different image sources with null safety
    final profileImage = widget.attendee.profileImage;

    if (profileImage != null && profileImage.isNotEmpty && !_hasImageError) {
      // Check if it's base64 data
      if (_isBase64(profileImage)) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
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
          child: ClipOval(
            child: Image.memory(
              base64Decode(profileImage),
              fit: BoxFit.cover,
              width: 92,
              height: 92,
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
          ),
        );
      } else {
        // It's a regular URL
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
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
          child: ClipOval(
            child: Image.network(
              profileImage,
              fit: BoxFit.cover,
              width: 92,
              height: 92,
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
          ),
        );
      }
    } else {
      // No image, show initials
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Center(
        child: Text(
          _getInitials(widget.attendee.fullName),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260, maxHeight: 300),
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
                    // Profile Avatar with image or initials
                    _buildAttendeeAvatar(),
                    const SizedBox(height: 16),

                    // Name
                    Flexible(
                      child: Text(
                        widget.attendee.fullName,
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

                    // Event Name
                    Flexible(
                      child: Text(
                        widget.eventName,
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
                    const SizedBox(height: 12),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(hasAttended),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        hasAttended ? 'ATTENDED' : 'REGISTERED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  Color _getStatusColor(bool hasAttended) {
    return hasAttended ? AppConstants.successColor : AppConstants.warningColor;
  }
}
