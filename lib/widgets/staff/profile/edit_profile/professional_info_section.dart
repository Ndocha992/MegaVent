import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';

class StaffProfessionalInformationSection extends StatelessWidget {
  final TextEditingController organizationController;
  final TextEditingController jobTitleController;
  final TextEditingController websiteController;
  final VoidCallback onFieldChanged;

  const StaffProfessionalInformationSection({
    super.key,
    required this.organizationController,
    required this.jobTitleController,
    required this.websiteController,
    required this.onFieldChanged,
  });

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
      onChanged: (_) => onFieldChanged(),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Professional Information',
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: organizationController,
          label: 'Organization',
          icon: Icons.business_outlined,
          hint: 'Enter your organization name',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: jobTitleController,
          label: 'Job Title',
          icon: Icons.badge_outlined,
          hint: 'Enter your job title',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: websiteController,
          label: 'Website',
          icon: Icons.language_outlined,
          hint: 'Enter your website URL',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}