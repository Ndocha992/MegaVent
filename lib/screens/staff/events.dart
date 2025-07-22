import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/screens/staff/events_details.dart';
import 'package:megavent/widgets/staff/events/event_card.dart';
import 'package:megavent/widgets/staff/events/event_filters.dart';
import 'package:megavent/widgets/staff/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';

class StaffEvents extends StatefulWidget {
  const StaffEvents({super.key});

  @override
  State<StaffEvents> createState() => _StaffEventsState();
}

class _StaffEventsState extends State<StaffEvents>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/staff-events';

  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late DatabaseService _databaseService;
  List<Event> _events = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;
  String? _organizerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
    ); // Changed from 3 to 4
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _loadStaffOrganizerId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Add method to load staff organizer ID
  Future<void> _loadStaffOrganizerId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final staffDoc =
            await FirebaseFirestore.instance
                .collection('staff')
                .doc(user.uid)
                .get();

        if (staffDoc.exists) {
          setState(() {
            _organizerId = staffDoc.data()?['organizerId'];
          });
          await _initializeData();
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load staff data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeData() async {
    if (_organizerId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load categories
      _categories = ['All', ..._databaseService.getEventCategories()];

      // Load events
      await _loadEvents();
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (_organizerId == null) return;

    try {
      // Get events for the staff's organizer
      final events = await _databaseService.getEventsForOrganizer(
        _organizerId!,
      );

      setState(() {
        _events = events;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  // Helper method to check if event is ongoing
  bool _isEventOngoing(Event event) {
    DateTime now = DateTime.now();
    return event.startDate.isBefore(now) && event.endDate.isAfter(now);
  }

  List<Event> get _filteredEvents {
    List<Event> events = List.from(_events);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      events =
          events
              .where(
                (event) =>
                    event.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    event.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    event.location.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      events =
          events.where((event) => event.category == _selectedCategory).toList();
    }

    // Filter by tab
    DateTime now = DateTime.now();
    switch (_tabController.index) {
      case 0: // All Events
        break;
      case 1: // Upcoming
        events = events.where((event) => event.startDate.isAfter(now)).toList();
        break;
      case 2: // Ongoing
        events = events.where((event) => _isEventOngoing(event)).toList();
        break;
      case 3: // Past
        events = events.where((event) => event.endDate.isBefore(now)).toList();
        break;
    }

    return events;
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
      drawer: StaffSidebar(currentRoute: currentRoute),
      body:
          _isLoading
              ? _buildLoadingState()
              : _error != null
              ? _buildErrorState()
              : Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  _buildSearchAndFilters(),
                  Expanded(child: _buildEventsList()),
                ],
              ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SpinKitThreeBounce(color: AppConstants.primaryColor, size: 20.0),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppConstants.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error Loading Events',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Events Management', style: AppConstants.headlineLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and organize your events',
                    style: AppConstants.bodyLarge.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_events.length} Events',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final upcomingCount =
        _events
            .where((event) => event.startDate.isAfter(DateTime.now()))
            .length;
    final ongoingCount =
        _events.where((event) => _isEventOngoing(event)).length;
    final pastCount =
        _events.where((event) => event.endDate.isBefore(DateTime.now())).length;

    return Row(
      children: [
        _buildStatCard('Upcoming', upcomingCount, AppConstants.primaryColor),
        const SizedBox(width: 8),
        _buildStatCard('Ongoing', ongoingCount, AppConstants.successColor),
        const SizedBox(width: 8),
        _buildStatCard('Past', pastCount, AppConstants.textSecondaryColor),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorWeight: 3,
        isScrollable: true,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Ongoing'),
          Tab(text: 'Past'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppConstants.textSecondaryColor,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: AppConstants.primaryColor,
                  ),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
          if (_selectedCategory != 'All') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCategory,
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = 'All'),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredEvents.length} results',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final filteredEvents = _filteredEvents;

    if (filteredEvents.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: AppConstants.backgroundColor,
      child: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StaffEventCard(
                event: filteredEvents[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              StaffEventsDetails(event: filteredEvents[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppConstants.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No events yet',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'Events will are created by your Organizer',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StaffEventFilters(
            selectedCategory: _selectedCategory,
            categories: _categories, // Pass categories list
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
              Navigator.pop(context);
            },
          ),
    );
  }
}
