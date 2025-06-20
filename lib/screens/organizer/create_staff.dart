import 'package:flutter/material.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_action_buttons.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_forms.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_header.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_profile_section.dart';
import 'package:megavent/widgets/organizer/staff/create_staff/create_staff_section_header.dart';

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
  final TextEditingController _profileUrlController = TextEditingController();

  // Dropdown values
  String? _selectedRole;
  String? _selectedDepartment;
  bool _isNew = true; // Default to true for new staff

  // Available options
  late List<String> _roles;
  late List<String> _departments;

  @override
  void initState() {
    super.initState();
    _initializeRolesAndDepartments();
  }

  void _initializeRolesAndDepartments() {
    // Extract unique roles from existing staff data
    Set<String> rolesSet = FakeData.staff.map((staff) => staff.role).toSet();

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
    ]);

    // Extract unique departments from existing staff data
    Set<String> departmentsSet =
        FakeData.staff.map((staff) => staff.department).toSet();

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

    _roles = rolesSet.toList()..sort();
    _departments = departmentsSet.toList()..sort();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _profileUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                profileUrlController: _profileUrlController,
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
                        _showSnackBar('Camera feature coming soon');
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _showSnackBar('Gallery feature coming soon');
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.link_outlined,
                      label: 'URL',
                      onTap: () {
                        Navigator.pop(context);
                        _showSnackBar('Use the Profile Image URL field above');
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

  void _handleCreateStaff() {
    if (_formKey.currentState!.validate()) {
      // Generate a unique ID (in real app, this would be handled by backend)
      final now = DateTime.now();
      final staffId = now.millisecondsSinceEpoch.toString();

      // Generate initials for placeholder profile image
      final nameParts = _nameController.text.trim().split(' ');
      final initials = nameParts
          .map((name) => name.isNotEmpty ? name[0].toUpperCase() : '')
          .join('');

      // Create staff object with form data
      final staffData = {
        'id': staffId,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'department': _selectedDepartment,
        'profileUrl':
            _profileUrlController.text.trim().isEmpty
                ? 'https://via.placeholder.com/150/6B46C1/FFFFFF?text=$initials'
                : _profileUrlController.text.trim(),
        'hiredAt': now,
        'isNew': _isNew,
      };

      // Show success message
      _showSnackBar(
        '${_nameController.text.trim()} has been added to the team successfully!',
        isSuccess: true,
      );

      // Navigate back to staff list
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? AppConstants.successColor : AppConstants.primaryColor,
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
