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
  
  // Store original values for comparison
  Map<String, dynamic> _originalValues = {};

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
      
      // Store original values
      _originalValues = {
        'fullName': organizer.fullName,
        'email': organizer.email,
        'phone': organizer.phone,
        'organization': organizer.organization,
        'jobTitle': organizer.jobTitle,
        'bio': organizer.bio,
        'website': organizer.website,
        'address': organizer.address,
        'city': organizer.city,
        'country': organizer.country,
        'profileImage': organizer.profileImage,
      };
      
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

  // Helper method to get safe string value
  String? _getSafeStringValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  // Helper method to check if a field has changed
  bool _hasFieldChanged(String fieldName, dynamic newValue) {
    return _originalValues[fieldName] != newValue;
  }

  // Build update map with only changed fields
  Map<String, dynamic> _buildUpdateMap() {
    final Map<String, dynamic> updateMap = {};
    
    // Check each field for changes
    final String fullName = _fullNameController.text.trim();
    if (_hasFieldChanged('fullName', fullName) && fullName.isNotEmpty) {
      updateMap['fullName'] = fullName;
    }
    
    final String email = _emailController.text.trim();
    if (_hasFieldChanged('email', email) && email.isNotEmpty) {
      updateMap['email'] = email;
    }
    
    final String phone = _phoneController.text.trim();
    if (_hasFieldChanged('phone', phone) && phone.isNotEmpty) {
      updateMap['phone'] = phone;
    }
    
    final String? organization = _getSafeStringValue(_organizationController.text);
    if (_hasFieldChanged('organization', organization)) {
      updateMap['organization'] = organization;
    }
    
    final String? jobTitle = _getSafeStringValue(_jobTitleController.text);
    if (_hasFieldChanged('jobTitle', jobTitle)) {
      updateMap['jobTitle'] = jobTitle;
    }
    
    final String? bio = _getSafeStringValue(_bioController.text);
    if (_hasFieldChanged('bio', bio)) {
      updateMap['bio'] = bio;
    }
    
    final String? website = _getSafeStringValue(_websiteController.text);
    if (_hasFieldChanged('website', website)) {
      updateMap['website'] = website;
    }
    
    final String? address = _getSafeStringValue(_addressController.text);
    if (_hasFieldChanged('address', address)) {
      updateMap['address'] = address;
    }
    
    final String? city = _getSafeStringValue(_cityController.text);
    if (_hasFieldChanged('city', city)) {
      updateMap['city'] = city;
    }
    
    final String? country = _getSafeStringValue(_countryController.text);
    if (_hasFieldChanged('country', country)) {
      updateMap['country'] = country;
    }
    
    // Check profile image
    if (_hasFieldChanged('profileImage', _selectedImageBase64)) {
      updateMap['profileImage'] = _selectedImageBase64;
    }
    
    // Always update the timestamp if there are changes
    if (updateMap.isNotEmpty) {
      updateMap['updatedAt'] = DateTime.now();
    }
    
    return updateMap;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentOrganizer == null) {
      return;
    }

    // Build update map with only changed fields
    final updateMap = _buildUpdateMap();
    
    if (updateMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected'),
          backgroundColor: Colors.orange,
        ),
      );
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

      // Use the new update method that only updates changed fields
      await databaseService.updateOrganizerProfileFields(
        _currentOrganizer!.id,
        updateMap,
      );

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
      builder: (context) => AlertDialog(
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
        stream: Provider.of<DatabaseService>(
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
                screenTitle: 'Edit Profile',
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
                      onPressed: () => setState(() {
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
              screenTitle: organizer.fullName,
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
                      fullName: organizer.fullName,
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