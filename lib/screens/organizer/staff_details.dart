import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_actions_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_contact_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_department_role_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_header.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_hire_date_status_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_info_section.dart';

class StaffDetails extends StatefulWidget {
  final Staff? staff;

  const StaffDetails({super.key, this.staff});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-staff';
  late Staff currentStaff;

  @override
  void initState() {
    super.initState();
    // Use passed staff or default to first staff from fake data
    currentStaff = widget.staff ?? FakeData.staff.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentStaff.name),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff Header with Profile Image
            StaffHeaderWidget(staff: currentStaff),

            // Staff Info Section
            StaffInfoSectionWidget(staff: currentStaff),

            // Contact Information
            StaffContactSectionWidget(
              staff: currentStaff,
              onEmailTap: _launchEmail,
              onPhoneTap: _launchPhone,
            ),

            // Department & Role Info
            StaffDepartmentRoleSectionWidget(staff: currentStaff),

            // Hire Date & Status
            StaffHireDateStatusSectionWidget(staff: currentStaff),

            // Action Buttons
            StaffActionsSectionWidget(
              staff: currentStaff,
              onEdit: _handleEditStaff,
              onDelete: _handleDeleteStaff,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleEditStaff() {
    // Navigate to edit staff screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${currentStaff.name}'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleDeleteStaff() {
    _showDeleteConfirmationDialog();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_remove_outlined,
                  color: AppConstants.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Remove Staff'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${currentStaff.name}" from the team? This action cannot be undone.',
            style: AppConstants.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteStaff();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _deleteStaff() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${currentStaff.name} has been removed from the team'),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // Navigate back to staff list
    Navigator.of(context).pop();
  }

  void _launchEmail(String email) {
    // Implement email launching functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email to $email'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _launchPhone(String phone) {
    // Implement phone calling functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
