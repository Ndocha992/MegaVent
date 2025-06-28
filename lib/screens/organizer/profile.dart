import 'package:flutter/material.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/profile/action_buttons.dart';
import 'package:megavent/widgets/organizer/profile/contact_info_section.dart';
import 'package:megavent/widgets/organizer/profile/personal_info_section.dart';
import 'package:megavent/widgets/organizer/profile/professional_info_section.dart';
import 'package:megavent/widgets/organizer/profile/profile_header_card.dart';
import 'package:megavent/widgets/organizer/profile/stats_overview.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/screens/organizer/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-profile';
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
      appBar: OrganizerAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: StreamBuilder<Organizer?>(
          key: _streamBuilderKey, // Add key to force rebuild
          stream: databaseService.streamCurrentOrganizerData(),
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading overlay if not already showing
              if (!_isLoading) {
                _isLoading = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoadingOverlay.show(
                    context,
                    message: 'Loading your profile...',
                  );
                });
              }

              // Return empty container while loading overlay is shown
              return Container();
            } else {
              // Hide loading overlay when data is loaded
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
                child: Container(
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

            final organizer = snapshot.data;
            if (organizer == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: Text('No organizer data available'),
                  ),
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
                  ProfileHeaderCard(organizer: organizer),
                  const SizedBox(height: 20),
                  // Stats Overview
                  StatsOverview(
                    organizer: organizer,
                    databaseService: databaseService,
                  ),
                  const SizedBox(height: 20),
                  // Personal Information
                  PersonalInfoSection(
                    organizer: organizer,
                    databaseService: databaseService,
                  ),
                  const SizedBox(height: 20),
                  // Contact Information
                  ContactInfoSection(
                    organizer: organizer,
                    onEmailTap: _launchEmail,
                    onPhoneTap: _launchPhone,
                  ),
                  const SizedBox(height: 20),
                  // Professional Information
                  ProfessionalInfoSection(
                    organizer: organizer,
                    onWebsiteTap: _launchUrl,
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons
                  ActionButtons(onEditProfile: _editProfile),
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
      MaterialPageRoute(builder: (context) => const EditProfile()),
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

  void _launchUrl(String url) async {
    try {
      // Ensure URL has a scheme
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not launch website');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening website: ${e.toString()}');
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
