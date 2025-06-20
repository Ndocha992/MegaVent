import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/create_staff.dart';
import 'package:megavent/screens/organizer/staff_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Staff> get _filteredStaff {
    List<Staff> staffList = FakeData.staff;

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

  void _navigateToCreateStaff() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateStaff()));
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
          Expanded(
            child: StaffList(
              staffList: _filteredStaff,
              onStaffTap: _onStaffTap,
              onAddStaff: _navigateToCreateStaff,
              searchQuery: _searchQuery,
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
