import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/admin.dart';
import 'package:megavent/screens/loading_screen.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/profile/edit_profile/action_buttons_section.dart';
import 'package:megavent/widgets/admin/profile/edit_profile/contact_information_section.dart';
import 'package:megavent/widgets/admin/profile/edit_profile/personal_information_section.dart';
import 'package:megavent/widgets/admin/profile/edit_profile/profile_image_section.dart';
import 'package:megavent/widgets/admin/sidebar.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
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
  String currentRoute = '/admin-profile';

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showPasswordSection = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isInitialized = false;
  String? _selectedImageBase64;
  Admin? _currentAdmin;

  // Store original values for comparison
  Map<String, dynamic> _originalValues = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFields(Admin admin) {
    if (_currentAdmin?.id != admin.id) {
      _currentAdmin = admin;

      // Store original values
      _originalValues = {
        'fullName': admin.fullName,
        'email': admin.email,
        'phone': admin.phone,
        'profileImage': admin.profileImage,
      };

      _fullNameController.text = admin.fullName;
      _emailController.text = admin.email;
      _phoneController.text = admin.phone;
      _selectedImageBase64 = admin.profileImage;

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

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _showPasswordSection = false);
      } else {
        _showErrorSnackBar(result['message']);
      }
    } catch (e) {
      _showErrorSnackBar('Password change failed: ${e.toString()}');
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  Widget _buildPasswordSection() {
    if (!_showPasswordSection) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppConstants.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.warningColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppConstants.warningColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Password Settings',
                    style: AppConstants.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.warningColor,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _showPasswordSection = true),
                  icon: Icon(
                    Icons.edit,
                    color: AppConstants.warningColor,
                    size: 16,
                  ),
                  label: Text(
                    'Change Password',
                    style: TextStyle(
                      color: AppConstants.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppConstants.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.warningColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppConstants.warningColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Change Password',
                style: AppConstants.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.warningColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Current Password Field
        TextFormField(
          controller: _currentPasswordController,
          obscureText: true,
          onChanged: (_) => _onFieldChanged(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your current password';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Current Password',
            hintText: 'Enter your current password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppConstants.warningColor,
            ),
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
              borderSide: BorderSide(
                color: AppConstants.warningColor,
                width: 2,
              ),
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
        ),
        const SizedBox(height: 16),

        // New Password Field
        TextFormField(
          controller: _newPasswordController,
          obscureText: true,
          onChanged: (_) => _onFieldChanged(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a new password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: Icon(
              Icons.lock_reset,
              color: AppConstants.warningColor,
            ),
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
              borderSide: BorderSide(
                color: AppConstants.warningColor,
                width: 2,
              ),
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
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          onChanged: (_) => _onFieldChanged(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your new password';
            }
            if (value != _newPasswordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            hintText: 'Re-enter your new password',
            prefixIcon: Icon(
              Icons.lock_reset,
              color: AppConstants.warningColor,
            ),
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
              borderSide: BorderSide(
                color: AppConstants.warningColor,
                width: 2,
              ),
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
        ),
        const SizedBox(height: 20),

        // Password Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showPasswordSection = false;
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppConstants.warningColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppConstants.warningColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isChangingPassword ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.warningColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child:
                    _isChangingPassword
                        ? const SpinKitThreeBounce(
                          color: AppConstants.warningColor,
                          size: 20.0,
                        )
                        : const Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentAdmin == null) {
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
      await databaseService.updateAdminProfileFields(
        _currentAdmin!.id,
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
      child: StreamBuilder<Admin?>(
        stream:
            Provider.of<DatabaseService>(
              context,
              listen: false,
            ).streamCurrentAdminData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isInitialized) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppConstants.backgroundColor,
              appBar: NestedScreenAppBar(screenTitle: 'Edit Profile'),
              drawer: AdminSidebar(currentRoute: currentRoute),
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
              drawer: AdminSidebar(currentRoute: currentRoute),
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

          final admin = snapshot.data;
          if (admin == null) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppConstants.backgroundColor,
              appBar: NestedScreenAppBar(screenTitle: 'Edit Profile'),
              drawer: AdminSidebar(currentRoute: currentRoute),
              body: const Center(child: Text('No admin data available')),
            );
          }

          // Populate fields when data is available
          if (!_isInitialized || _currentAdmin?.id != admin.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFields(admin);
            });
          }

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppConstants.backgroundColor,
            appBar: NestedScreenAppBar(screenTitle: admin.fullName),
            drawer: AdminSidebar(currentRoute: currentRoute),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    AdminProfileImageSection(
                      selectedImageBase64:
                          _selectedImageBase64 ?? admin.profileImage,
                      fullName: admin.fullName,
                      onImageChanged: _onImageChanged,
                    ),
                    const SizedBox(height: 32),

                    // Personal Information Section
                    AdminPersonalInformationSection(
                      fullNameController: _fullNameController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 24),

                    // Contact Information Section
                    AdminContactInformationSection(
                      emailController: _emailController,
                      phoneController: _phoneController,
                      onFieldChanged: _onFieldChanged,
                    ),
                    const SizedBox(height: 24),

                    // Add password section
                    _buildPasswordSection(),

                    const SizedBox(height: 32),

                    // Action Buttons
                    AdminActionButtonsSection(
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
