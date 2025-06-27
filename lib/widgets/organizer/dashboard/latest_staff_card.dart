import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/organizer/create_staff.dart';
import 'package:megavent/screens/organizer/staff_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';

class LatestStaffCard extends StatelessWidget {
  final List<Staff> staff;

  const LatestStaffCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Staff', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/organizer-staff');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppConstants.cardDecoration,
          child:
              staff.isEmpty
                  ? _buildEmptyStaffState(context)
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: staff.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final staffMember = staff[index];
                      return GestureDetector(
                        onTap: () => _onStaffTap(context, staffMember),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: StaffAvatarWithLoading(staff: staffMember),
                          title: Text(
                            // Fixed: Use consistent property access
                            staffMember.fullName.isNotEmpty
                                ? staffMember.fullName
                                : staffMember.name,
                            style: AppConstants.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                staffMember.role,
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                staffMember.department,
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                staffMember.email,
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: StaffUtils.getDepartmentColor(
                                    staffMember.department,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  staffMember.department,
                                  style: AppConstants.bodySmall.copyWith(
                                    color: StaffUtils.getDepartmentColor(
                                      staffMember.department,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Fixed: Ensure proper date formatting
                                'Hired ${StaffUtils.formatHireDate(staffMember.hiredAt)}',
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyStaffState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No Staff Members Yet',
              style: AppConstants.titleMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first staff member to get started',
              textAlign: TextAlign.center,
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateStaff()),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStaffTap(BuildContext context, Staff staff) {
    // Fixed: Ensure complete staff data is passed
    debugPrint('Staff data being passed: ${staff.toString()}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StaffDetails(staff: staff)),
    );
  }
}

class StaffAvatarWithLoading extends StatefulWidget {
  final Staff staff;

  const StaffAvatarWithLoading({super.key, required this.staff});

  @override
  State<StaffAvatarWithLoading> createState() => _StaffAvatarWithLoadingState();
}

class _StaffAvatarWithLoadingState extends State<StaffAvatarWithLoading> {
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                StaffUtils.getDepartmentColor(
                  widget.staff.department,
                ).withOpacity(0.8),
                StaffUtils.getDepartmentColor(widget.staff.department),
              ],
            ),
          ),
          child:
              _isNetworkImageLoading
                  ? _buildLoadingIndicator()
                  : _buildAvatarContent(),
        ),
        // Fixed: Properly check isNew status and positioning
        if (widget.staff.isNew == true)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppConstants.successColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
              ),
              child: const Icon(Icons.fiber_new, size: 8, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SpinKitThreeBounce(color: Colors.white, size: 16.0),
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
            width: 48,
            height: 48,
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
            width: 48,
            height: 48,
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
        // Fixed: Use consistent property access and handle safely
        StaffUtils.getInitials(
          widget.staff.fullName.isNotEmpty
              ? widget.staff.fullName
              : widget.staff.name,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
