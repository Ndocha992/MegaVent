import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/screens/attendee/events_details.dart';
import 'package:megavent/widgets/attendee/events/event_card.dart';
import 'package:megavent/widgets/attendee/events/event_filters.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';

class AttendeeAllEvents extends StatefulWidget {
  const AttendeeAllEvents({super.key});

  @override
  State<AttendeeAllEvents> createState() => _AttendeeAllEventsState();
}

class _AttendeeAllEventsState extends State<AttendeeAllEvents>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = 'attendee-all-events'; // Fixed route name

  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late DatabaseService _databaseService;
  List<Event> _events = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
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
    try {
      // Listen to ALL events stream (not just organizer events)
      _databaseService.streamAllEvents().listen(
        (events) {
          if (mounted) {
            setState(() {
              _events = events;
              _isLoading = false;
              _error = null;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Failed to load events: ${error.toString()}';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: ${e.toString()}';
        _isLoading = false;
      });
    }
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
                    ) ||
                    event.description.toLowerCase().contains(
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
      case 2: // Past
        events =
            events.where((event) => event.startDate.isBefore(now)).toList();
        break;
    }

    // Sort events by start date (upcoming first, then past events in reverse)
    events.sort((a, b) {
      if (a.startDate.isAfter(now) && b.startDate.isAfter(now)) {
        // Both upcoming - earliest first
        return a.startDate.compareTo(b.startDate);
      } else if (a.startDate.isBefore(now) && b.startDate.isBefore(now)) {
        // Both past - latest first
        return b.startDate.compareTo(a.startDate);
      } else if (a.startDate.isAfter(now)) {
        // a is upcoming, b is past - a comes first
        return -1;
      } else {
        // a is past, b is upcoming - b comes first
        return 1;
      }
    });

    return events;
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Browse Events',
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: AttendeeSidebar(currentRoute: currentRoute),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'Error Loading Events',
                style: AppConstants.titleLarge.copyWith(
                  color: AppConstants.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
          // Title and event count - now stacked vertically for better space management
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Events',
                style: AppConstants.headlineLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                'Find and join amazing events happening around you',
                style: AppConstants.bodyLarge.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              // Event count badge
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
                    Flexible(
                      child: Text(
                        '${_events.length} Events',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
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
    final pastCount =
        _events
            .where((event) => event.startDate.isBefore(DateTime.now()))
            .length;
    final todayCount =
        _events
            .where(
              (event) =>
                  event.startDate.year == DateTime.now().year &&
                  event.startDate.month == DateTime.now().month &&
                  event.startDate.day == DateTime.now().day,
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Upcoming',
            upcomingCount,
            AppConstants.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Today', todayCount, AppConstants.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Past',
            pastCount,
            AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
        tabs: const [
          Tab(text: 'All Events'),
          Tab(text: 'Upcoming'),
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
                      hintText: 'Search events, categories, locations...',
                      hintStyle: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
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
                Flexible(
                  child: Container(
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
                        Flexible(
                          child: Text(
                            _selectedCategory,
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap:
                              () => setState(() => _selectedCategory = 'All'),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              child: AttendeeEventCard(
                event: filteredEvents[index],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => AttendeeEventsDetails(
                            event: filteredEvents[index],
                          ),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                'No events found',
                style: AppConstants.titleLarge.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty || _selectedCategory != 'All'
                    ? 'Try adjusting your search or filter criteria'
                    : 'No events are available at the moment',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              if (_searchQuery.isNotEmpty || _selectedCategory != 'All') ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'All';
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AttendeeEventFilters(
            selectedCategory: _selectedCategory,
            categories: _categories,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
              Navigator.pop(context);
            },
          ),
    );
  }
}
