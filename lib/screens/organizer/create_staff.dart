import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_action_buttons.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_forms.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_header.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_profile_section.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_section_header.dart';
import 'package:provider/provider.dart';

class CreateStaff extends StatefulWidget {
  const CreateStaff({super.key});

  @override
  State<CreateStaff> createState() => _CreateStaffState();
}

class _CreateStaffState extends State<CreateStaff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentRoute = '/organizer-staff';

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Profile image
  String? _profileImageBase64;

  // Dropdown values
  String? _selectedRole;
  String? _selectedDepartment;
  bool _isNew = true; // Default to true for new staff

  // Available options
  List<String> _roles = [];
  List<String> _departments = [];

  // Loading states
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: NestedScreenAppBar(screenTitle: 'Create Staff'),
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
      appBar: NestedScreenAppBar(screenTitle: 'Create Staff'),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const CreateStaffHeader(),
              const SizedBox(height: 24),

              // Profile Section
              CreateStaffProfileSection(
                profileImageBase64: _profileImageBase64,
                staffName: _nameController.text.trim(),
                onImagePickerTap: _showImagePickerOptions,
              ),
              const SizedBox(height: 24),

              // Personal Information Section
              const CreateStaffSectionHeader(
                title: 'Personal Information',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CreateStaffPersonalInfoForm(
                nameController: _nameController,
                onNameChanged: () => setState(() {}), // Refresh initials
              ),
              const SizedBox(height: 24),

              // Contact Information Section
              const CreateStaffSectionHeader(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
              ),
              const SizedBox(height: 16),
              CreateStaffContactInfoForm(
                emailController: _emailController,
                phoneController: _phoneController,
              ),
              const SizedBox(height: 24),

              // Work Information Section
              const CreateStaffSectionHeader(
                title: 'Work Information',
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              CreateStaffWorkInfoForm(
                selectedRole: _selectedRole,
                selectedDepartment: _selectedDepartment,
                isNew: _isNew,
                roles: _roles,
                departments: _departments,
                onRoleChanged: (value) => setState(() => _selectedRole = value),
                onDepartmentChanged:
                    (value) => setState(() => _selectedDepartment = value),
                onNewStatusChanged: (value) => setState(() => _isNew = value),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              CreateStaffActionButtons(
                onCancel: () => Navigator.of(context).pop(),
                onCreate: _handleCreateStaff,
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
                  'Add Profile Photo',
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

  Future<void> _handleCreateStaff() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null || _selectedDepartment == null) {
      _showSnackBar('Please select both role and department', isSuccess: false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final databaseService = context.read<DatabaseService>();

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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hiredAt: DateTime.now(),
      );

      await databaseService.addStaff(newStaff);

      _showSnackBar(
        '${_nameController.text} has been added to the team',
        isSuccess: true,
      );

      // Navigate back after a short delay to show the success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar(
        'Failed to create staff member: ${e.toString()}',
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
