import 'package:flutter/material.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

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
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final nameParts = name.trim().split(' ');
    final initials = nameParts
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join('');
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(_fullNameController.text.trim());
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child:
            initials.isNotEmpty
                ? Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.person, size: 50, color: Colors.white),
      ),
    );
  }

  Widget _buildImageAvatar() {
    try {
      final imageBytes = base64Decode(_selectedImageBase64!);
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildInitialsAvatar(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              _selectedImageBase64 != null
                  ? _buildImageAvatar()
                  : _buildInitialsAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.secondaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _selectedImageBase64 != null
                          ? Icons.edit_outlined
                          : Icons.photo_camera_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedImageBase64 != null
                ? 'Tap to change photo'
                : 'Add Profile Photo',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optional but recommended',
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppConstants.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => _onFieldChanged(),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBase64 = base64Encode(bytes);
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBase64 = base64Encode(bytes);
        _hasChanges = true;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppConstants.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Update Profile Photo',
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.photo_camera_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                    if (_selectedImageBase64 != null)
                      _buildImageOption(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedImageBase64 = null;
                            _hasChanges = true;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppConstants.bodySmall),
        ],
      ),
    );
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

      Navigator.pop(context);
    } catch (e) {
      LoadingOverlay.hide();
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: NestedScreenAppBar(
          screenTitle: _currentOrganizer?.fullName ?? 'Edit Profile',
        ),
        drawer: OrganizerSidebar(currentRoute: currentRoute),
        body: StreamBuilder<Organizer?>(
          stream:
              Provider.of<DatabaseService>(
                context,
                listen: false,
              ).streamCurrentOrganizerData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!LoadingOverlay.isShowing) {
                  LoadingOverlay.show(
                    context,
                    message: 'Loading profile data...',
                  );
                }
              });
              return Container();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (LoadingOverlay.isShowing) {
                LoadingOverlay.hide();
              }
            });

            if (snapshot.hasError) {
              return Center(
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
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final organizer = snapshot.data;
            if (organizer == null) {
              return const Center(child: Text('No organizer data available'));
            }

            if (_currentOrganizer == null ||
                _currentOrganizer!.id != organizer.id) {
              _populateFields(organizer);
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    _buildProfileSection(),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    _buildSectionHeader(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      icon: Icons.info_outline,
                      hint: 'Tell us about yourself',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Contact Information Section
                    _buildSectionHeader(
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Professional Information Section
                    _buildSectionHeader(
                      title: 'Professional Information',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _organizationController,
                      label: 'Organization',
                      icon: Icons.business_outlined,
                      hint: 'Enter your organization name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _jobTitleController,
                      label: 'Job Title',
                      icon: Icons.badge_outlined,
                      hint: 'Enter your job title',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language_outlined,
                      hint: 'Enter your website URL',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // Location Information Section
                    _buildSectionHeader(
                      title: 'Location Information',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      hint: 'Enter your address',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cityController,
                            label: 'City',
                            icon: Icons.location_city_outlined,
                            hint: 'Enter your city',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _countryController,
                            label: 'Country',
                            icon: Icons.flag_outlined,
                            hint: 'Enter your country',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppConstants.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
