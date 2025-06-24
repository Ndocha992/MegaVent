import 'package:flutter/material.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/organizer/edit_staff.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_actions_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_contact_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_department_role_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_header.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_hire_date_status_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_info_section.dart';
import 'package:provider/provider.dart';

class StaffDetails extends StatefulWidget {
  final Staff? staff;
  final String? staffId; // Add staffId parameter for when staff is null

  const StaffDetails({super.key, this.staff, this.staffId});

  @override
  State<StaffDetails> createState() => _StaffDetailsState();
}

class _StaffDetailsState extends State<StaffDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-staff';
  Staff? currentStaff;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeStaff();
  }

  void _initializeStaff() {
    if (widget.staff != null) {
      currentStaff = widget.staff;
      isLoading = false;
    } else {
      _loadStaffData();
    }
  }

  void _loadStaffData() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final staffList = await databaseService.getAllStaff();
      
      if (staffList.isNotEmpty) {
        if (widget.staffId != null) {
          // Find staff by ID
          currentStaff = staffList.firstWhere(
            (staff) => staff.id == widget.staffId,
            orElse: () => staffList.first,
          );
        } else {
          // Use first staff if no specific ID provided
          currentStaff = staffList.first;
        }
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load staff data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: const NestedScreenAppBar(screenTitle: 'Loading...'),
        drawer: OrganizerSidebar(currentRoute: currentRoute),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: const NestedScreenAppBar(screenTitle: 'Error'),
        drawer: OrganizerSidebar(currentRoute: currentRoute),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: AppConstants.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    error = null;
                    isLoading = true;
                  });
                  _loadStaffData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (currentStaff == null) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.backgroundColor,
        appBar: const NestedScreenAppBar(screenTitle: 'No Staff Found'),
        drawer: OrganizerSidebar(currentRoute: currentRoute),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 64,
                color: AppConstants.textSecondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No staff members found',
                style: AppConstants.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add staff members to view their details',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentStaff!.name),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff Header with Profile Image
            StaffHeaderWidget(staff: currentStaff!),

            // Staff Info Section
            StaffInfoSectionWidget(staff: currentStaff!),

            // Contact Information
            StaffContactSectionWidget(
              staff: currentStaff!,
              onEmailTap: _launchEmail,
              onPhoneTap: _launchPhone,
            ),

            // Department & Role Info
            StaffDepartmentRoleSectionWidget(staff: currentStaff!),

            // Hire Date & Status
            StaffHireDateStatusSectionWidget(staff: currentStaff!),

            // Action Buttons
            StaffActionsSectionWidget(
              staff: currentStaff!,
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditStaff(staff: currentStaff!)),
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
            'Are you sure you want to remove "${currentStaff!.name}" from the team? This action cannot be undone.',
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

  void _deleteStaff() async {
    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      await databaseService.deleteStaff(currentStaff!.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${currentStaff!.name} has been removed from the team'),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Navigate back to staff list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete staff: $e'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _launchEmail(String email) {
    // Implement email launching functionality
    // You can use url_launcher package: launch('mailto:$email')
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
    // You can use url_launcher package: launch('tel:$phone')
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phone'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}