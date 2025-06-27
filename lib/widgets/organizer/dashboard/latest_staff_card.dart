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
                            staffMember.fullName,
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
                                StaffUtils.formatHireDate(staffMember.hiredAt),
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
                  : _buildProfileImage(),
        ),
        if (widget.staff.isNew)
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

  Widget _buildProfileImage() {
    if (widget.staff.profileImage != null &&
        widget.staff.profileImage!.isNotEmpty &&
        !_hasImageError) {
      // Check if it's a base64 encoded image with data URL prefix
      if (widget.staff.profileImage!.startsWith('data:image/')) {
        return _buildBase64Image(widget.staff);
      }
      // Check if it's a base64 string without prefix
      else if (_isBase64String(widget.staff.profileImage!)) {
        return _buildBase64ImageFromString(widget.staff);
      }
      // Handle network images
      else if (widget.staff.profileImage!.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            widget.staff.profileImage!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
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
          ),
        );
      }
    }

    // Default to initials avatar
    return _buildInitialsAvatar();
  }

  Widget _buildBase64Image(Staff staffMember) {
    try {
      // Extract base64 data from data URL
      final base64Data = staffMember.profileImage!.split(',')[1];
      final bytes = base64Decode(base64Data);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 48,
          height: 48,
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
          // No loadingBuilder for Image.memory - it loads instantly
        ),
      );
    } catch (e) {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildBase64ImageFromString(Staff staffMember) {
    try {
      final bytes = base64Decode(staffMember.profileImage!);

      return ClipOval(
        child: Image.memory(
          bytes,
          width: 48,
          height: 48,
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
          // No loadingBuilder for Image.memory - it loads instantly
        ),
      );
    } catch (e) {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        StaffUtils.getInitials(widget.staff.fullName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  bool _isBase64String(String str) {
    try {
      // Basic check for base64 string
      final regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return regex.hasMatch(str) && str.length % 4 == 0;
    } catch (e) {
      return false;
    }
  }
}
