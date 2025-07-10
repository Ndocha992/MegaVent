import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';

class OrganizerList extends StatelessWidget {
  final List<Staff> staffList;
  final Function(Staff) onStaffTap;
  final VoidCallback onAddStaff;
  final String searchQuery;

  const OrganizerList({
    super.key,
    required this.staffList,
    required this.onStaffTap,
    required this.onAddStaff,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (staffList.isEmpty) {
      return OrganizerEmptyState(searchQuery: searchQuery, onAddStaff: onAddStaff);
    }

    return Container(
      color: AppConstants.backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: StaffCard(
              staff: staffList[index],
              onTap: () => onStaffTap(staffList[index]),
            ),
          );
        },
      ),
    );
  }
}

class StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback onTap;

  const StaffCard({super.key, required this.staff, required this.onTap});

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
              OrganizerAvatar(staff: staff),
              const SizedBox(width: 16),
              Expanded(child: OrganizerInfo(staff: staff)),
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
  final Staff staff;

  const OrganizerAvatar({super.key, required this.staff});

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
                _getDepartmentColor(widget.staff.department).withOpacity(0.8),
                _getDepartmentColor(widget.staff.department),
              ],
            ),
          ),
          child:
              _isNetworkImageLoading
                  ? _buildLoadingIndicator()
                  : _buildAvatarContent(),
        ),
        if (widget.staff.isNew)
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
    final profileImage = widget.staff.profileImage;

    if (profileImage != null && profileImage.isNotEmpty && !_hasImageError) {
      if (_isBase64(profileImage)) {
        // Base64 images load instantly, no loading builder needed
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
        // Network images need loading builder
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
        StaffUtils.getInitials(widget.staff.name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    return StaffUtils.getDepartmentColor(department);
  }
}

class OrganizerInfo extends StatelessWidget {
  final Staff staff;

  const OrganizerInfo({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                staff.fullName,
                style: AppConstants.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            OrganizerDepartmentChip(department: staff.department),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          staff.role,
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        OrganizerInfoRow(icon: Icons.email_outlined, text: staff.email),
        const SizedBox(height: 4),
        OrganizerInfoRow(
          icon: Icons.access_time,
          text: 'Hired ${StaffUtils.formatHireDate(staff.hiredAt)}',
        ),
      ],
    );
  }
}

class OrganizerDepartmentChip extends StatelessWidget {
  final String department;

  const OrganizerDepartmentChip({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDepartmentColor(department).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        department,
        style: AppConstants.bodySmall.copyWith(
          color: _getDepartmentColor(department),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    return StaffUtils.getDepartmentColor(department);
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
  final VoidCallback onAddStaff;

  const OrganizerEmptyState({
    super.key,
    required this.searchQuery,
    required this.onAddStaff,
  });

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
                Icons.people_outline,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No organizer found',
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
