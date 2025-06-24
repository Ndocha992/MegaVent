import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:megavent/models/attendee.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/screens/organizer/attendees_details.dart';
import 'package:megavent/utils/constants.dart';
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

  // State variables for data loading
  List<Attendee> _allAttendees = [];
  List<String> _availableEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load attendees from the database
  Future<void> _loadAttendees() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final databaseService = Provider.of<DatabaseService>(
        context,
        listen: false,
      );

      // Get all attendees for current organizer's events
      final attendees = await databaseService.getAllAttendees();

      // Extract unique event names for filtering
      final eventNames = AttendeesUtils.getUniqueEvents(attendees);

      setState(() {
        _allAttendees = attendees;
        _availableEvents = eventNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load attendees: $e';
        _isLoading = false;
      });
    }
  }

  // Refresh attendees data
  Future<void> _refreshAttendees() async {
    await _loadAttendees();
  }

  List<Attendee> get _filteredAttendees {
    List<Attendee> attendeesList = List.from(_allAttendees);

    // Apply search filter
    attendeesList = AttendeesUtils.filterAttendeesBySearch(
      attendeesList,
      _searchQuery,
    );

    // Apply event filter
    attendeesList = AttendeesUtils.filterAttendeesByEvent(
      attendeesList,
      _selectedEvent,
    );

    // Apply tab filter
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
            availableEvents: _availableEvents,
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshAttendees,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading attendees...', style: TextStyle(fontSize: 16)),
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
          const Text(
            'No attendees found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Attendees will appear here once they register for your events',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshAttendees,
            child: const Text('Refresh'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAttendees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Column(
        children: [
          const AttendeesHeader(),
          AttendeesTabBar(
            tabController: _tabController,
            onTabChanged: (index) => setState(() {}),
          ),
          if (!_isLoading && _errorMessage == null) ...[
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
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAttendees,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_allAttendees.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredAttendees.isEmpty &&
        (_searchQuery.isNotEmpty || _selectedEvent != 'All')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No attendees match your filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedEvent = 'All';
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return AttendeesList(
      attendeesList: _filteredAttendees,
      onAttendeeTap: _onAttendeeTap,
      searchQuery: _searchQuery,
    );
  }
}
