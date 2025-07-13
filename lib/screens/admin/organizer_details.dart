import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/organizer/edit_staff.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_actions_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_contact_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_department_role_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_header.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_hire_date_status_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_info_section.dart';
import 'package:megavent/widgets/organizer/staff/staff_details/staff_password_section.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizerDetails extends StatefulWidget {
  final Organizer? organizer;
  final String? organizerId;

  const OrganizerDetails({super.key, this.organizer, this.organizerId});

  @override
  State<OrganizerDetails> createState() => _OrganizerDetailsState();
}

class _OrganizerDetailsState extends State<OrganizerDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/admin-organizer';
  Staff? currentStaff;
  Organizer? currentOrganizer;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeStaff();
  }

  void _initializeStaff() {
    if (widget.organizer != null) {
      currentOrganizer = widget.organizer;
      setState(() {
        isLoading = false;
      });
    } else if (widget.organizerId != null) {
      _loadOrganizerById(widget.organizerId!);
    } else {
      _loadFirstOrganizer();
    }
  }

  Future<void> _loadOrganizerById(String staffId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Check authentication
      if (databaseService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get all staff and find the specific one
      final staffList = await databaseService.getAllStaff();
      final staff = staffList.firstWhere(
        (s) => s.id == staffId,
        orElse: () => throw Exception('Staff member not found'),
      );

      setState(() {
        currentStaff = staff;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load staff member: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadFirstOrganizer() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Check authentication
      if (databaseService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final staffList = await databaseService.getAllStaff();

      if (staffList.isNotEmpty) {
        setState(() {
          currentStaff = staffList.first;
          isLoading = false;
        });
      } else {
        setState(() {
          currentStaff = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load staff data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshStaffData() async {
    if (currentStaff != null) {
      await _loadOrganizerById(currentStaff!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (error != null) {
      return _buildErrorScreen();
    }

    if (currentStaff == null) {
      return _buildNoStaffScreen();
    }

    return _buildStaffDetailsScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'Loading...'),
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

  Widget _buildErrorScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'Error'),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppConstants.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: AppConstants.headlineMedium.copyWith(
                  color: AppConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConstants.textSecondaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        error = null;
                        isLoading = true;
                      });
                      _initializeStaff();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoStaffScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'No Staff Found'),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.textSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No staff members found',
                style: AppConstants.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Add staff members to view their details',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffDetailsScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentStaff!.fullName),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: _refreshStaffData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Header with Profile Image
              StaffHeaderWidget(staff: currentStaff!),

              // Staff Info Section
              StaffInfoSectionWidget(staff: currentStaff!),

              // Default Password
              StaffPasswordSection(),

              const SizedBox(height: 20),

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
      ),
    );
  }

  void _handleEditStaff() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditStaff(staff: currentStaff!)),
    );

    // Refresh staff data if edited
    if (result == true) {
      await _refreshStaffData();
    }
  }

  void _handleDeleteStaff() {
    _showDeleteConfirmationDialog();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              const Expanded(
                child: Text('Remove Staff', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${currentStaff!.fullName}" from the team? This action cannot be undone.',
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
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => SizedBox(
              width: 20,
              height: 20,
              child: Container(
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: AppConstants.primaryColor,
                    size: 20.0,
                  ),
                ),
              ),
            ),
      );

      // Use AuthService to delete staff (handles both Auth and Firestore)
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.deleteStaff(currentStaff!.id);

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${currentStaff!.fullName} has been removed from the team',
              ),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate back to staff list
          Navigator.of(context).pop();
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete staff'),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete staff: $e'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(scheme: 'mailto', path: email);

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showLaunchErrorSnackBar('email client', email);
      }
    } catch (e) {
      _showLaunchErrorSnackBar('email client', email);
    }
  }

  Future<void> _launchPhone(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showLaunchErrorSnackBar('phone app', phone);
      }
    } catch (e) {
      _showLaunchErrorSnackBar('phone app', phone);
    }
  }

  void _showLaunchErrorSnackBar(String appType, String contact) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open $appType for $contact'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
