import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/services/auth_service.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/widgets/admin/sidebar.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_actions_section.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_contact_section.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_organization_section.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_header.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_registration_section.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_info_section.dart';
import 'package:megavent/widgets/admin/organizer/organizer_details/organizer_approval_section.dart';
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
  String currentRoute = '/admin-organizers';
  Organizer? currentOrganizer;
  AdminOrganizerStats? adminOrganizerStats;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeOrganizer();
  }

  Future<void> _loadOrganizerStats() async {
    if (currentOrganizer == null) return;

    final databaseService = Provider.of<DatabaseService>(
      context,
      listen: false,
    );
    adminOrganizerStats = await databaseService.getAdminOrganizerStats(
      currentOrganizer!.id,
    );
    setState(() {});
  }

  void _initializeOrganizer() {
    if (widget.organizer != null) {
      currentOrganizer = widget.organizer;

      // After loading organizer, load stats
      if (currentOrganizer != null) {
        _loadOrganizerStats();
      }
      setState(() {
        isLoading = false;
      });
    } else if (widget.organizerId != null) {
      _loadOrganizerById(widget.organizerId!);
    } else {
      _loadFirstOrganizer();
    }
  }

  Future<void> _loadOrganizerById(String organizerId) async {
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

      // Get all organizers and find the specific one
      final organizersList = await databaseService.getAdminAllOrganizers();
      final organizer = organizersList.firstWhere(
        (o) => o.id == organizerId,
        orElse: () => throw Exception('Organizer not found'),
      );

      setState(() {
        currentOrganizer = organizer;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load organizer: $e';
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

      final organizersList = await databaseService.getAdminAllOrganizers();

      if (organizersList.isNotEmpty) {
        setState(() {
          currentOrganizer = organizersList.first;
          isLoading = false;
        });
      } else {
        setState(() {
          currentOrganizer = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load organizer data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshOrganizerData() async {
    if (currentOrganizer != null) {
      await _loadOrganizerById(currentOrganizer!.id);
      await _loadOrganizerStats();
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

    if (currentOrganizer == null) {
      return _buildNoOrganizerScreen();
    }

    return _buildOrganizerDetailsScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'Loading...'),
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

  Widget _buildErrorScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'Error'),
      drawer: AdminSidebar(currentRoute: currentRoute),
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
                      _initializeOrganizer();
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

  Widget _buildNoOrganizerScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: const NestedScreenAppBar(screenTitle: 'No Organizers Found'),
      drawer: AdminSidebar(currentRoute: currentRoute),
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
                  Icons.business_center_outlined,
                  size: 48,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text('No organizers found', style: AppConstants.headlineMedium),
              const SizedBox(height: 12),
              Text(
                'No organizers are currently registered',
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

  Widget _buildOrganizerDetailsScreen() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: currentOrganizer!.fullName),
      drawer: AdminSidebar(currentRoute: currentRoute),
      body: RefreshIndicator(
        onRefresh: _refreshOrganizerData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Organizer Header with Profile Image
              OrganizerHeaderWidget(organizer: currentOrganizer!),

              // Organizer Info Section
              OrganizerInfoSectionWidget(organizer: currentOrganizer!),

              const SizedBox(height: 20),

              // Contact Information
              OrganizerContactSectionWidget(
                organizer: currentOrganizer!,
                onEmailTap: _launchEmail,
                onPhoneTap: _launchPhone,
              ),

              // Organization Info
              OrganizerOrganizationSectionWidget(organizer: currentOrganizer!),

              // Registration Date & Status
              OrganizerRegistrationSectionWidget(organizer: currentOrganizer!),

              // Approval Section
              OrganizerApprovalSectionWidget(
                organizer: currentOrganizer!,
                onApprovalToggle: _handleApprovalToggle,
              ),

              // Action Buttons
              OrganizerActionsSectionWidget(
                organizer: currentOrganizer!,
                stats: adminOrganizerStats,
                onDelete: _handleDeleteOrganizer,
                onViewEvents: _handleViewEvents,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleApprovalToggle() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SpinKitThreeBounce(
                  color: AppConstants.primaryColor,
                  size: 20.0,
                ),
              ),
            ),
      );

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Toggle approval status
      final newApprovalStatus = !currentOrganizer!.isApproved;
      await databaseService.updateOrganizerApproval(
        currentOrganizer!.id,
        newApprovalStatus,
      );

      // Update local state
      setState(() {
        currentOrganizer = currentOrganizer!.copyWith(
          isApproved: newApprovalStatus,
        );
      });

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newApprovalStatus
                  ? '${currentOrganizer!.fullName} has been approved'
                  : '${currentOrganizer!.fullName} approval has been revoked',
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update approval status: $e'),
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

  void _handleDeleteOrganizer() {
    _showDeleteConfirmationDialog();
  }

  void _handleViewEvents() {
    // Navigate to organizer's events
    // You can implement this based on your event management system
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing events for ${currentOrganizer!.fullName}'),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                child: Text('Remove Organizer', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${currentOrganizer!.fullName}" from the platform? This action cannot be undone and will also remove all their events.',
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
                _deleteOrganizer();
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

  void _deleteOrganizer() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SpinKitThreeBounce(
                  color: AppConstants.primaryColor,
                  size: 20.0,
                ),
              ),
            ),
      );

      // Use AuthService to delete organizer
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.deleteOrganizer(currentOrganizer!.id);

      // Hide loading indicator
      if (mounted) Navigator.of(context).pop();

      if (result['success']) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${currentOrganizer!.fullName} has been removed from the platform',
              ),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate back to organizer list
          Navigator.of(context).pop();
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to delete organizer'),
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
            content: Text('Failed to delete organizer: $e'),
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
