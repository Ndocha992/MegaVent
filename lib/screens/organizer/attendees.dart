import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/attendees_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_header.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_tab_bar.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_search_filters.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_list.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_filters_dialog.dart';
import 'package:megavent/widgets/organizer/attendees/attendee_qr_dialog.dart';
import 'package:megavent/utils/organizer/attendees/attendees_utils.dart';

class Attendees extends StatefulWidget {
  const Attendees({super.key});

  @override
  State<Attendees> createState() => _AttendeesState();
}

class _AttendeesState extends State<Attendees> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-attendees';

  late TabController _tabController;
  String _selectedEvent = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Attendee> get _filteredAttendees {
    List<Attendee> attendeesList = FakeData.attendees;

    // Apply filters using utility functions
    attendeesList = AttendeesUtils.filterAttendeesBySearch(
      attendeesList,
      _searchQuery,
    );
    attendeesList = AttendeesUtils.filterAttendeesByEvent(
      attendeesList,
      _selectedEvent,
    );
    attendeesList = AttendeesUtils.filterAttendeesByStatus(
      attendeesList,
      _selectedStatus,
    );
    attendeesList = AttendeesUtils.filterAttendeesByTab(
      attendeesList,
      _tabController.index,
    );

    return attendeesList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AttendeesFiltersDialog(
            selectedEvent: _selectedEvent,
            selectedStatus: _selectedStatus,
            onEventChanged: (event) {
              setState(() => _selectedEvent = event);
              Navigator.pop(context);
            },
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _onAttendeeTap(Attendee attendee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendeesDetails(attendee: attendee),
      ),
    );
  }

  void _showAttendeeQR(Attendee attendee) {
    showDialog(
      context: context,
      builder: (context) => AttendeeQRDialog(attendee: attendee),
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
          const AttendeesHeader(),
          AttendeesTabBar(
            tabController: _tabController,
            onTabChanged: (index) => setState(() {}),
          ),
          AttendeesSearchFilters(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedEvent: _selectedEvent,
            selectedStatus: _selectedStatus,
            filteredAttendeesCount: _filteredAttendees.length,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onFilterPressed: _showFilterDialog,
            onEventCleared: () => setState(() => _selectedEvent = 'All'),
            onStatusCleared: () => setState(() => _selectedStatus = 'All'),
          ),
          Expanded(
            child: AttendeesList(
              attendeesList: _filteredAttendees,
              onAttendeeTap: _onAttendeeTap,
              onShowQR: _showAttendeeQR,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}
