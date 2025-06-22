import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class CreateStaffPersonalInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onNameChanged;

  const CreateStaffPersonalInfoForm({
    super.key,
    required this.nameController,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateStaffTextFormField(
          controller: nameController,
          onChanged: (value) => onNameChanged(),
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter full name';
            }
            if (value.trim().split(' ').length < 2) {
              return 'Please enter both first and last name';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class CreateStaffContactInfoForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const CreateStaffContactInfoForm({
    super.key,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateStaffTextFormField(
          controller: emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email address';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        CreateStaffTextFormField(
          controller: phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            // Basic phone validation - accepts +254 format or local format
            if (!RegExp(
              r'^(\+254|0)[17]\d{8}$',
            ).hasMatch(value.replaceAll(' ', ''))) {
              return 'Please enter a valid phone number (e.g., +254712345678)';
            }
            return null;
          },
          onChanged: (value) {},
        ),
      ],
    );
  }
}

class CreateStaffWorkInfoForm extends StatelessWidget {
  final String? selectedRole;
  final String? selectedDepartment;
  final bool isNew;
  final List<String> roles;
  final List<String> departments;
  final void Function(String?) onRoleChanged;
  final void Function(String?) onDepartmentChanged;
  final void Function(bool) onNewStatusChanged;

  const CreateStaffWorkInfoForm({
    super.key,
    required this.selectedRole,
    required this.selectedDepartment,
    required this.isNew,
    required this.roles,
    required this.departments,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onNewStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateStaffDropdownField(
          value: selectedRole,
          label: 'Role',
          icon: Icons.work_outline,
          items: roles,
          onChanged: onRoleChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a role';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CreateStaffDropdownField(
          value: selectedDepartment,
          label: 'Department',
          icon: Icons.business_outlined,
          items: departments,
          onChanged: onDepartmentChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a department';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CreateStaffSwitchTile(isNew: isNew, onChanged: onNewStatusChanged),
      ],
    );
  }
}

class CreateStaffTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final void Function(String) onChanged;

  const CreateStaffTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: AppConstants.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
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
          borderSide: BorderSide(color: AppConstants.errorColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

class CreateStaffDropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CreateStaffDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
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
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: AppConstants.bodyMedium),
            );
          }).toList(),
    );
  }
}

class CreateStaffSwitchTile extends StatelessWidget {
  final bool isNew;
  final void Function(bool) onChanged;

  const CreateStaffSwitchTile({
    super.key,
    required this.isNew,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.new_releases_outlined, color: AppConstants.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Staff Member', style: AppConstants.bodyMedium),
                Text(
                  'Mark as new to show "NEW" badge',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isNew,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}
