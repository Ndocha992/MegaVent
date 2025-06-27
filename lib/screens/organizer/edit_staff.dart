import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/edit_staff/staff_action_buttons.dart';
import 'package:megavent/widgets/organizer/staff/edit_staff/staff_contact_info_form.dart';
import 'package:megavent/widgets/organizer/staff/edit_staff/staff_personal_info_form.dart';
import 'package:megavent/widgets/organizer/staff/edit_staff/staff_section_header.dart';
import 'package:megavent/widgets/organizer/staff/edit_staff/staff_work_info_form.dart';
import 'package:provider/provider.dart';

class EditStaff extends StatefulWidget {
  final Staff? staff;

  const EditStaff({super.key, this.staff});

  @override
  State<EditStaff> createState() => _EditStaffState();
}

class _EditStaffState extends State<EditStaff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentRoute = '/organizer-staff';

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Profile image
  String? _profileImageBase64;

  // Dropdown values
  String? _selectedRole;
  String? _selectedDepartment;

  // Available options
  List<String> _roles = [];
  List<String> _departments = [];

  // Loading states
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadStaffData();
  }

  void _initializeForm() {
    final staff = widget.staff;

    _nameController = TextEditingController(text: staff?.fullName ?? '');
    _emailController = TextEditingController(text: staff?.email ?? '');
    _phoneController = TextEditingController(text: staff?.phone ?? '');

    _selectedRole = staff?.role;
    _selectedDepartment = staff?.department;

    _profileImageBase64 = staff?.profileImage;
  }

  Future<void> _loadStaffData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final databaseService = context.read<DatabaseService>();
      final allStaff = await databaseService.getAllStaff();

      _initializeRolesAndDepartments(allStaff);
    } catch (e) {
      // If we can't load existing staff data, use default values
      _initializeDefaultRolesAndDepartments();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeRolesAndDepartments(List<Staff> staffList) {
    // Extract unique roles from existing staff data
    Set<String> rolesSet = staffList.map((staff) => staff.role).toSet();

    // Add additional roles that might not exist in current data
    rolesSet.addAll([
      'Event Manager',
      'Event Coordinator',
      'Marketing Specialist',
      'Technical Support',
      'Operations Manager',
      'Sales Representative',
      'Customer Service',
      'Finance Manager',
      'HR Specialist',
      'Security Officer',
      'Graphics Designer',
      'Project Manager',
      'Social Media Manager',
      'Content Creator',
      'Business Analyst',
    ]);

    // Extract unique departments from existing staff data
    Set<String> departmentsSet =
        staffList.map((staff) => staff.department).toSet();

    // Add additional departments that might not exist in current data
    departmentsSet.addAll([
      'Operations',
      'Marketing',
      'Technical',
      'Sales',
      'Finance',
      'Human Resources',
      'Security',
      'Customer Service',
      'Creative',
      'IT',
    ]);

    setState(() {
      _roles = rolesSet.toList()..sort();
      _departments = departmentsSet.toList()..sort();
    });
  }

  void _initializeDefaultRolesAndDepartments() {
    setState(() {
      _roles = [
        'Event Manager',
        'Event Coordinator',
        'Marketing Specialist',
        'Technical Support',
        'Operations Manager',
        'Sales Representative',
        'Customer Service',
        'Finance Manager',
        'HR Specialist',
        'Security Officer',
        'Graphics Designer',
        'Project Manager',
        'Social Media Manager',
        'Content Creator',
        'Business Analyst',
      ]..sort();

      _departments = [
        'Operations',
        'Marketing',
        'Technical',
        'Sales',
        'Finance',
        'Human Resources',
        'Security',
        'Customer Service',
        'Creative',
        'IT',
      ]..sort();
    });
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _profileImageBase64 = base64Encode(bytes));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _profileImageBase64 = base64Encode(bytes));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
    final initials = _getInitials(_nameController.text.trim());
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
      final imageBytes = base64Decode(_profileImageBase64!);
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
      // If base64 decoding fails, show initials avatar
      return _buildInitialsAvatar();
    }
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              _profileImageBase64 != null
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
                      _profileImageBase64 != null
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
            _profileImageBase64 != null
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: NestedScreenAppBar(
          screenTitle: widget.staff?.fullName ?? 'Add New Staff',
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(
        screenTitle: widget.staff?.fullName ?? 'Add New Staff',
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildProfileSection(),
              const SizedBox(height: 24),

              // Personal Information Section
              const StaffSectionHeader(
                title: 'Personal Information',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              StaffPersonalInfoForm(
                nameController: _nameController,
                onNameChanged: () => setState(() {}), // Refresh initials
              ),
              const SizedBox(height: 24),

              // Contact Information Section
              const StaffSectionHeader(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
              ),
              const SizedBox(height: 16),
              StaffContactInfoForm(
                emailController: _emailController,
                phoneController: _phoneController,
              ),
              const SizedBox(height: 24),

              // Work Information Section
              const StaffSectionHeader(
                title: 'Work Information',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              StaffWorkInfoForm(
                selectedRole: _selectedRole,
                selectedDepartment: _selectedDepartment,
                roles: _roles,
                departments: _departments,
                onRoleChanged: (value) => setState(() => _selectedRole = value),
                onDepartmentChanged:
                    (value) => setState(() => _selectedDepartment = value),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              StaffActionButtons(
                isEditing: widget.staff != null,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _handleSaveStaff,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
                    if (_profileImageBase64 != null)
                      _buildImageOption(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _profileImageBase64 = null);
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

  Future<void> _handleSaveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null || _selectedDepartment == null) {
      _showSnackBar('Please select both role and department', isSuccess: false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final databaseService = context.read<DatabaseService>();
      final now = DateTime.now();

      if (widget.staff != null) {
        // Update existing staff
        final updatedStaff = widget.staff!.copyWith(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole!,
          department: _selectedDepartment!,
          profileImage: _profileImageBase64,
          updatedAt: now,
        );

        await databaseService.updateStaff(updatedStaff);

        _showSnackBar(
          '${_nameController.text} has been updated successfully',
          isSuccess: true,
        );
      } else {
        // Create new staff
        final newStaff = Staff(
          id: '', // Will be set by the database service
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          profileImage: _profileImageBase64,
          organizerId: '', // Will be set by the database service
          role: _selectedRole!,
          department: _selectedDepartment!,
          isApproved: true,
          createdAt: now,
          updatedAt: now,
          hiredAt: now, // This determines if staff is "new"
        );

        await databaseService.addStaff(newStaff);

        _showSnackBar(
          '${_nameController.text} has been added to the team',
          isSuccess: true,
        );
      }

      // Navigate back after a short delay to show the success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar(
        'Failed to save staff member: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? AppConstants.successColor : AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
