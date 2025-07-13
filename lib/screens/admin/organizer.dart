import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/models/organizer.dart';
import 'package:megavent/screens/admin/organizer_details.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/admin/organizer/organizer_header.dart';
import 'package:megavent/widgets/admin/organizer/organizer_list.dart';
import 'package:megavent/widgets/admin/organizer/organizer_search_filters.dart';
import 'package:megavent/widgets/admin/organizer/organizer_tab_bar.dart';
import 'package:megavent/widgets/admin/sidebar.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class OrganizerScreen extends StatefulWidget {
  const OrganizerScreen({super.key});

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/admin-organizer';

  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Data management
  List<Organizer> _allOrganizers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrganizersData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load organizers data using DatabaseService
  Future<void> _loadOrganizersData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Check if user is authenticated
      if (databaseService.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch all organizers
      final List<Organizer> organizersList =
          await databaseService.getAdminAllOrganizers();

      setState(() {
        _allOrganizers = organizersList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load organizers: $e';
        _isLoading = false;
      });
    }
  }

  List<Organizer> get _filteredOrganizers {
    List<Organizer> organizersList = List.from(_allOrganizers);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      organizersList =
          organizersList.where((organizer) {
            final searchLower = _searchQuery.toLowerCase();
            return organizer.fullName.toLowerCase().contains(searchLower) ||
                organizer.email.toLowerCase().contains(searchLower) ||
                (organizer.organization ?? '').toLowerCase().contains(
                  searchLower,
                );
          }).toList();
    }

    // Apply tab filter
    switch (_tabController.index) {
      case 0: // All Organizers
        break;
      case 1: // Pending
        organizersList =
            organizersList.where((organizer) {
              return organizer.isApproved == false;
            }).toList();
        break;
      case 2: // Approved
        organizersList =
            organizersList.where((organizer) {
              return organizer.isApproved == true;
            }).toList();
        break;
    }

    return organizersList;
  }

  void _onOrganizerTap(Organizer organizer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerDetails(organizer: organizer),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SpinKitThreeBounce(color: AppConstants.primaryColor, size: 20.0),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrganizersData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text('No organizers found', style: AppConstants.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Approve your first organizer to get started',
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: AdminSidebar(currentRoute: currentRoute),
      body: Column(
        children: [
          OrganizerHeader(),
          OrganizerTabBar(
            tabController: _tabController,
            onTabChanged: (index) => setState(() {}),
          ),
          if (!_isLoading) ...[
            OrganizerSearchFilters(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onClearSearch: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrganizersData,
              child:
                  _isLoading
                      ? _buildLoadingState()
                      : _error != null
                      ? _buildErrorState()
                      : _allOrganizers.isEmpty
                      ? _buildEmptyState()
                      : OrganizerList(
                        organizersList: _filteredOrganizers,
                        onOrganizerTap: _onOrganizerTap,
                        searchQuery: _searchQuery,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
