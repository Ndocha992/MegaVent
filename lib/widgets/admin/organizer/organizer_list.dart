import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/utils/constants.dart';

class OrganizerList extends StatelessWidget {
  final List<Organizer> organizersList;
  final Function(Organizer) onOrganizerTap;
  final String searchQuery;

  const OrganizerList({
    super.key,
    required this.organizersList,
    required this.onOrganizerTap,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (organizersList.isEmpty) {
      return OrganizerEmptyState(searchQuery: searchQuery);
    }

    return Container(
      color: AppConstants.backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: organizersList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrganizerCard(
              organizer: organizersList[index],
              onTap: () => onOrganizerTap(organizersList[index]),
            ),
          );
        },
      ),
    );
  }
}

class OrganizerCard extends StatelessWidget {
  final Organizer organizer;
  final VoidCallback onTap;

  const OrganizerCard({
    super.key,
    required this.organizer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppConstants.cardDecoration.copyWith(
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OrganizerAvatar(organizer: organizer),
              const SizedBox(width: 16),
              Expanded(child: OrganizerInfo(organizer: organizer)),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizerAvatar extends StatefulWidget {
  final Organizer organizer;

  const OrganizerAvatar({super.key, required this.organizer});

  @override
  State<OrganizerAvatar> createState() => _OrganizerAvatarState();
}

class _OrganizerAvatarState extends State<OrganizerAvatar> {
  bool _isNetworkImageLoading = false;
  bool _hasImageError = false;

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
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                _getStatusColor(
                  widget.organizer.approvalStatus,
                ).withOpacity(0.8),
                _getStatusColor(widget.organizer.approvalStatus),
              ],
            ),
          ),
          child:
              _isNetworkImageLoading
                  ? _buildLoadingIndicator()
                  : _buildAvatarContent(),
        ),
        if (widget.organizer.isApproved == false)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppConstants.successColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
              ),
              child: const Icon(Icons.fiber_new, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SpinKitThreeBounce(color: Colors.white, size: 20.0),
    );
  }

  Widget _buildAvatarContent() {
    final profileImage = widget.organizer.profileImage;

    if (profileImage != null && profileImage.isNotEmpty && !_hasImageError) {
      if (_isBase64(profileImage)) {
        return ClipOval(
          child: Image.memory(
            base64Decode(profileImage),
            fit: BoxFit.cover,
            width: 60,
            height: 60,
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
        return ClipOval(
          child: Image.network(
            profileImage,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
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
    return Center(
      child: Text(
        _getInitials(widget.organizer.fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        return AppConstants.successColor;
      case 'pending':
        return AppConstants.warningColor;
      case 'rejected':
      case 'inactive':
        return AppConstants.errorColor;
      default:
        return AppConstants.primaryColor;
    }
  }
}

class OrganizerInfo extends StatelessWidget {
  final Organizer organizer;

  const OrganizerInfo({super.key, required this.organizer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                organizer.fullName,
                style: AppConstants.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OrganizerStatusChip(status: organizer.approvalStatus),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          organizer.organization ?? 'No Organization',
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        OrganizerInfoRow(icon: Icons.email_outlined, text: organizer.email),
        const SizedBox(height: 4),
        OrganizerInfoRow(icon: Icons.phone_outlined, text: organizer.phone),
        const SizedBox(height: 4),
        OrganizerInfoRow(
          icon: Icons.access_time,
          text: 'Registered ${_formatDate(organizer.createdAt)}',
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class OrganizerStatusChip extends StatelessWidget {
  final String status;

  const OrganizerStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppConstants.bodySmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppConstants.successColor;
      case 'pending':
        return AppConstants.warningColor;
      default:
        return AppConstants.primaryColor;
    }
  }
}

class OrganizerInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const OrganizerInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppConstants.textSecondaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class OrganizerEmptyState extends StatelessWidget {
  final String searchQuery;

  const OrganizerEmptyState({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center_outlined,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No organizers found',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'Start by approving your first organizer',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
