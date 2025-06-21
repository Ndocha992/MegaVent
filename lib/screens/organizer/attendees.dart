import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/attendees_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_filters_dialog.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_header.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_tab_bar.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_search_filter.dart';
import 'package:megavent/widgets/organizer/attendees/attendees_list.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fixed: Changed from 4 to 3 tabs to match your tab bar
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Attendee> get _filteredAttendees {
    List<Attendee> attendeesList = FakeData.attendees;

    // Apply search filter
    attendeesList = AttendeesUtils.filterAttendeesBySearch(
      attendeesList,
      _searchQuery,
    );

    // Apply event filter - FIXED: Now properly filters by event
    attendeesList = _filterAttendeesByEvent(attendeesList, _selectedEvent);

    // Apply tab filter
    attendeesList = AttendeesUtils.filterAttendeesByTab(
      attendeesList,
      _tabController.index,
    );

    return attendeesList;
  }

  // FIXED: Proper event filtering implementation
  List<Attendee> _filterAttendeesByEvent(
    List<Attendee> attendees,
    String eventName,
  ) {
    if (eventName == 'All') return attendees;

    // Filter attendees by event name
    return attendees
        .where((attendee) => attendee.eventName == eventName)
        .toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AttendeesFiltersDialog(
            selectedEvent: _selectedEvent,
            onEventChanged: (event) {
              setState(() {
                _selectedEvent = event;
              });
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
          AttendeesSearchFilter(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedEvent: _selectedEvent,
            filteredAttendeesCount: _filteredAttendees.length,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onFilterPressed: _showFilterDialog,
            onEventCleared: () => setState(() => _selectedEvent = 'All'),
          ),
          Expanded(
            child: AttendeesList(
              attendeesList: _filteredAttendees,
              onAttendeeTap: _onAttendeeTap,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
    );
  }
}
