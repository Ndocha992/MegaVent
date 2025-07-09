import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/screens/staff/edit_profile.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/widgets/staff/profile/action_buttons.dart';
import 'package:megavent/widgets/staff/profile/contact_info_section.dart';
import 'package:megavent/widgets/staff/profile/personal_info_section.dart';
import 'package:megavent/widgets/staff/profile/professional_info_section.dart';
import 'package:megavent/widgets/staff/profile/profile_header_card.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffProfile extends StatefulWidget {
  const StaffProfile({super.key});

  @override
  State<StaffProfile> createState() => _StaffProfileState();
}

class _StaffProfileState extends State<StaffProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/staff-profile';
  bool _isLoading = false;
  // Add a key to force StreamBuilder rebuild
  Key _streamBuilderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: StaffSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: StreamBuilder<Staff?>(
          key: _streamBuilderKey,
          stream: databaseService.streamCurrentStaffData(),
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              if (!_isLoading) {
                _isLoading = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingOverlay.show(
                    context,
                    message: 'Loading your profile...',
                  );
                });
              }
              return Container();
            } else {
              if (_isLoading) {
                _isLoading = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingOverlay.hide();
                });
              }
            }

            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text('Error', style: AppConstants.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load profile data',
                          style: AppConstants.bodyLarge.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshProfile,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final staff = snapshot.data;
            if (staff == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(child: Text('No staff data available')),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profile Settings', style: AppConstants.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account and preferences',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Profile Header Card
                  StaffProfileHeaderCard(staff: staff),
                  const SizedBox(height: 20),
                  // Personal Information
                  StaffPersonalInfoSection(
                    staff: staff,
                    databaseService: databaseService,
                  ),
                  const SizedBox(height: 20),
                  // Contact Information
                  StaffContactInfoSection(
                    staff: staff,
                    onEmailTap: _launchEmail,
                    onPhoneTap: _launchPhone,
                  ),
                  const SizedBox(height: 20),
                  // Professional Information
                  StaffProfessionalInfoSection(staff: staff),
                  const SizedBox(height: 20),
                  // Action Buttons
                  StaffActionButtons(onEditProfile: _editProfile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure loading overlay is hidden when widget is disposed
    if (_isLoading) {
      LoadingOverlay.hide();
    }
    super.dispose();
  }

  // Add refresh method
  Future<void> _refreshProfile() async {
    setState(() {
      _streamBuilderKey = UniqueKey(); // Generate new key to force rebuild
    });

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StaffEditProfile()),
    );
  }

  void _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Hello from MegaVent',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('Could not launch email client');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening email: ${e.toString()}');
    }
  }

  void _launchPhone(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackBar('Could not launch phone dialer');
      }
    } catch (e) {
      _showErrorSnackBar('Error making call: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
