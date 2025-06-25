import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/action_buttons_section.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/contact_information_section.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/location_info_section.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/personal_information_section.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/professional_info_section.dart';
import 'package:megavent/widgets/organizer/profile/edit_profile/profile_image_section.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/services/database_service.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentRoute = '/organizer-profile';

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isInitialized = false;
  String? _selectedImageBase64;
  Organizer? _currentOrganizer;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _populateFields(Organizer organizer) {
    if (_currentOrganizer?.id != organizer.id) {
      _currentOrganizer = organizer;
      _fullNameController.text = organizer.fullName;
      _emailController.text = organizer.email;
      _phoneController.text = organizer.phone;
      _organizationController.text = organizer.organization ?? '';
      _jobTitleController.text = organizer.jobTitle ?? '';
      _bioController.text = organizer.bio ?? '';
      _websiteController.text = organizer.website ?? '';
      _addressController.text = organizer.address ?? '';
      _cityController.text = organizer.city ?? '';
      _countryController.text = organizer.country ?? '';
      _selectedImageBase64 = organizer.profileImage;

      _hasChanges = false;
      _isInitialized = true;
    }
  }

  void _onFieldChanged() {
    if (_isInitialized && !_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onImageChanged(String? imageBase64) {
    setState(() {
      _selectedImageBase64 = imageBase64;
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentOrganizer == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      LoadingOverlay.show(context, message: 'Updating your profile...');

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      final updatedOrganizer = _currentOrganizer!.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        organization:
            _organizationController.text.trim().isEmpty
                ? null
                : _organizationController.text.trim(),
        jobTitle:
            _jobTitleController.text.trim().isEmpty
                ? null
                : _jobTitleController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        website:
            _websiteController.text.trim().isEmpty
                ? null
                : _websiteController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
        country:
            _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
        profileImage: _selectedImageBase64 ?? _currentOrganizer!.profileImage,
        updatedAt: DateTime.now(),
      );

      await databaseService.updateOrganizerProfile(updatedOrganizer);

      LoadingOverlay.hide();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_fullNameController.text} profile updated successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        setState(() {
          _hasChanges = false;
        });

        Navigator.pop(context);
      }
    } catch (e) {
      LoadingOverlay.hide();
      if (mounted) {
        _showErrorSnackBar('Failed to update profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: StreamBuilder<Organizer?>(
        stream:
            Provider.of<DatabaseService>(
              context,
              listen: false,
            ).streamCurrentOrganizerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isInitialized) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppConstants.backgroundColor,
              appBar: NestedScreenAppBar(
                screenTitle: 'Edit Profile', // Default title while loading
              ),
              drawer: OrganizerSidebar(currentRoute: currentRoute),
              body: Container(
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: AppConstants.primaryColor,
                    size: 20.0,
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppConstants.backgroundColor,
              appBar: NestedScreenAppBar(screenTitle: 'Edit Profile'),
              drawer: OrganizerSidebar(currentRoute: currentRoute),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile data',
                      style: AppConstants.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () => setState(() {
                            _isInitialized = false;
                          }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final organizer = snapshot.data;
          if (organizer == null) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppConstants.backgroundColor,
              appBar: NestedScreenAppBar(screenTitle: 'Edit Profile'),
              drawer: OrganizerSidebar(currentRoute: currentRoute),
              body: const Center(child: Text('No organizer data available')),
            );
          }

          // Populate fields when data is available
          if (!_isInitialized || _currentOrganizer?.id != organizer.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFields(organizer);
            });
          }

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppConstants.backgroundColor,
            appBar: NestedScreenAppBar(
              screenTitle: organizer.fullName, // ✅ Now gets the actual name
            ),
            drawer: OrganizerSidebar(currentRoute: currentRoute),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    ProfileImageSection(
                      selectedImageBase64:
                          _selectedImageBase64 ?? organizer.profileImage,
                      fullName:
                          organizer
                              .fullName, // ✅ Use actual name from organizer
                      onImageChanged: _onImageChanged,
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    PersonalInformationSection(
                      fullNameController: _fullNameController,
                      bioController: _bioController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 24),

                    // Contact Information Section
                    ContactInformationSection(
                      emailController: _emailController,
                      phoneController: _phoneController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 24),

                    // Professional Information Section
                    ProfessionalInformationSection(
                      organizationController: _organizationController,
                      jobTitleController: _jobTitleController,
                      websiteController: _websiteController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 24),

                    // Location Information Section
                    LocationInformationSection(
                      addressController: _addressController,
                      cityController: _cityController,
                      countryController: _countryController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    ActionButtonsSection(
                      isLoading: _isLoading,
                      onCancel: () => Navigator.of(context).pop(),
                      onSave: _saveProfile,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
