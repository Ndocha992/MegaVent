import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megavent/models/staff.dart';
import 'package:megavent/screens/organizer/create_staff.dart';
import 'package:megavent/screens/organizer/staff_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/staff/staff_filters.dart';
import 'package:megavent/widgets/organizer/staff/staff_header.dart';
import 'package:megavent/widgets/organizer/staff/staff_tab_bar.dart';
import 'package:megavent/widgets/organizer/staff/staff_search_filters.dart';
import 'package:megavent/widgets/organizer/staff/staff_list.dart';
import 'package:megavent/utils/organizer/staff/staff_utils.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-staff';

  late TabController _tabController;
  String _selectedDepartment = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Add these for real data management
  List<Staff> _allStaff = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStaffData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load staff data from Firestore
  Future<void> _loadStaffData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Replace 'your_organizer_id' with actual organizer ID from auth/context
      final String organizerId = 'your_organizer_id'; // TODO: Get from auth

      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('staff')
              .where('organizerId', isEqualTo: organizerId)
              .orderBy('createdAt', descending: true)
              .get();

      final List<Staff> staffList =
          snapshot.docs.map((doc) => Staff.fromFirestore(doc)).toList();

      setState(() {
        _allStaff = staffList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load staff: $e';
        _isLoading = false;
      });
    }
  }

  List<Staff> get _filteredStaff {
    List<Staff> staffList = List.from(_allStaff);

    // Apply filters using utility functions
    staffList = StaffUtils.filterStaffBySearch(staffList, _searchQuery);
    staffList = StaffUtils.filterStaffByDepartment(
      staffList,
      _selectedDepartment,
    );
    staffList = StaffUtils.filterStaffByTab(staffList, _tabController.index);

    return staffList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StaffFilters(
            selectedDepartment: _selectedDepartment,
            onDepartmentChanged: (department) {
              setState(() => _selectedDepartment = department);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _onStaffTap(Staff staff) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StaffDetails(staff: staff)),
    );
  }

  void _navigateToCreateStaff() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateStaff()));

    // Refresh data if staff was created
    if (result == true) {
      _loadStaffData();
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Something went wrong',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadStaffData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first staff member to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateStaff,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Staff'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
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
      appBar: OrganizerAppBar(
        title: 'MegaVent',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Column(
        children: [
          StaffHeader(),
          StaffTabBar(
            tabController: _tabController,
            onTabChanged: (index) => setState(() {}),
          ),
          if (!_isLoading) ...[
            StaffSearchFilters(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedDepartment: _selectedDepartment,
              filteredStaffCount: _filteredStaff.length,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onClearSearch: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              onFilterPressed: _showFilterDialog,
              onDepartmentCleared:
                  () => setState(() => _selectedDepartment = 'All'),
            ),
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadStaffData,
              child:
                  _isLoading
                      ? _buildLoadingState()
                      : _error != null
                      ? _buildErrorState()
                      : _allStaff.isEmpty
                      ? _buildEmptyState()
                      : StaffList(
                        staffList: _filteredStaff,
                        onStaffTap: _onStaffTap,
                        onAddStaff: _navigateToCreateStaff,
                        searchQuery: _searchQuery,
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateStaff,
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Staff',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
