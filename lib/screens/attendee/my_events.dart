import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/screens/attendee/my_events_details.dart';
import 'package:megavent/widgets/attendee/events/event_card.dart';
import 'package:megavent/widgets/attendee/events/event_filters.dart';
import 'package:megavent/widgets/attendee/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/app_bar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendeeMyEvents extends StatefulWidget {
  const AttendeeMyEvents({super.key});

  @override
  State<AttendeeMyEvents> createState() => _AttendeeMyEventsState();
}

class _AttendeeMyEventsState extends State<AttendeeMyEvents>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/attendee-my-events';

  late TabController _tabController;

  // Enhanced filter state
  String _selectedCategory = 'All';
  String _selectedAvailability = 'All';
  String _selectedDateRange = 'All Time';
  String _selectedLocation = 'All Locations';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late DatabaseService _databaseService;
  List<Event> _registeredEvents = [];
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

      _categories = ['All', ..._databaseService.getEventCategories()];
      await _loadMyRegisteredEvents();
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMyRegisteredEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Get registered events for the current user
      final registeredEvents = await _databaseService.getMyRegisteredEvents(
        user.uid,
      );

      if (mounted) {
        setState(() {
          _registeredEvents = registeredEvents;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load registered events: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  List<Event> get _filteredEvents {
    List<Event> events = List.from(_registeredEvents);

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

    // Filter by availability
    if (_selectedAvailability != 'All') {
      events =
          events.where((event) {
            int availableSpots = event.capacity - event.registeredCount;
            double occupancyRate = event.registeredCount / event.capacity;

            switch (_selectedAvailability) {
              case 'Available Spots':
                return availableSpots > 0 && occupancyRate < 0.8;
              case 'Limited Spots':
                return availableSpots > 0 &&
                    occupancyRate >= 0.8 &&
                    occupancyRate < 0.95;
              case 'Almost Full':
                return availableSpots > 0 && occupancyRate >= 0.95;
              case 'Full':
                return availableSpots <= 0;
              default:
                return true;
            }
          }).toList();
    }

    // Filter by date range
    if (_selectedDateRange != 'All Time') {
      DateTime now = DateTime.now();
      events =
          events.where((event) {
            switch (_selectedDateRange) {
              case 'Today':
                return _isSameDay(event.startDate, now);
              case 'This Week':
                DateTime startOfWeek = now.subtract(
                  Duration(days: now.weekday - 1),
                );
                DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
                return event.startDate.isAfter(
                      startOfWeek.subtract(const Duration(days: 1)),
                    ) &&
                    event.startDate.isBefore(
                      endOfWeek.add(const Duration(days: 1)),
                    );
              case 'This Month':
                return event.startDate.year == now.year &&
                    event.startDate.month == now.month;
              case 'Next Month':
                DateTime nextMonth = DateTime(now.year, now.month + 1);
                return event.startDate.year == nextMonth.year &&
                    event.startDate.month == nextMonth.month;
              case 'Custom Range':
                // For now, show all events - in a real app, you'd implement date picker
                return true;
              default:
                return true;
            }
          }).toList();
    }

    // Filter by location
    if (_selectedLocation != 'All Locations') {
      if (_selectedLocation == 'Online Events') {
        events =
            events
                .where(
                  (event) =>
                      event.location.toLowerCase().contains('online') ||
                      event.location.toLowerCase().contains('virtual') ||
                      event.location.toLowerCase().contains('zoom') ||
                      event.location.toLowerCase().contains('meet'),
                )
                .toList();
      } else {
        events =
            events
                .where(
                  (event) => event.location.toLowerCase().contains(
                    _selectedLocation.toLowerCase(),
                  ),
                )
                .toList();
      }
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

    // Sort events by start date
    events.sort((a, b) {
      if (a.startDate.isAfter(now) && b.startDate.isAfter(now)) {
        return a.startDate.compareTo(b.startDate);
      } else if (a.startDate.isBefore(now) && b.startDate.isBefore(now)) {
        return b.startDate.compareTo(a.startDate);
      } else if (a.startDate.isAfter(now)) {
        return -1;
      } else {
        return 1;
      }
    });

    return events;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _refreshEvents() async {
    await _loadMyRegisteredEvents();
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
                'Error Loading Your Events',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Registered Events',
                style: AppConstants.headlineLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage events you have registered for',
                style: AppConstants.bodyLarge.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
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
                    const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${_filteredEvents.length} Registered Events',
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
          Tab(text: 'All Registered'),
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
                      hintText: 'Search your registered events...',
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
                  icon: Stack(
                    children: [
                      Icon(Icons.filter_list, color: AppConstants.primaryColor),
                      if (_hasActiveFilters())
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFilterDialog,
                ),
              ),
            ],
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(),
          ],
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != 'All' ||
        _selectedAvailability != 'All' ||
        _selectedDateRange != 'All Time' ||
        _selectedLocation != 'All Locations';
  }

  Widget _buildActiveFilters() {
    List<Widget> filterChips = [];

    if (_selectedCategory != 'All') {
      filterChips.add(
        _buildFilterChip(
          _selectedCategory,
          () => setState(() => _selectedCategory = 'All'),
          AppConstants.primaryColor,
        ),
      );
    }

    if (_selectedAvailability != 'All') {
      filterChips.add(
        _buildFilterChip(
          _selectedAvailability,
          () => setState(() => _selectedAvailability = 'All'),
          AppConstants.successColor,
        ),
      );
    }

    if (_selectedDateRange != 'All Time') {
      filterChips.add(
        _buildFilterChip(
          _selectedDateRange,
          () => setState(() => _selectedDateRange = 'All Time'),
          AppConstants.primaryColor,
        ),
      );
    }

    if (_selectedLocation != 'All Locations') {
      filterChips.add(
        _buildFilterChip(
          _selectedLocation,
          () => setState(() => _selectedLocation = 'All Locations'),
          AppConstants.secondaryColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Text(
                'Clear All',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: filterChips),
        const SizedBox(height: 8),
        Text(
          '${_filteredEvents.length} results',
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedAvailability = 'All';
      _selectedDateRange = 'All Time';
      _selectedLocation = 'All Locations';
    });
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
                          (context) => AttendeeMyEventsDetails(
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
                  Icons.event_note,
                  size: 60,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isNotEmpty || _hasActiveFilters()
                    ? 'No matching events found'
                    : 'No registered events yet',
                style: AppConstants.titleLarge.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty || _hasActiveFilters()
                    ? 'Try adjusting your search or filter criteria'
                    : 'You haven\'t registered for any events yet. Browse available events to get started!',
                textAlign: TextAlign.center,
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              if (_searchQuery.isNotEmpty || _hasActiveFilters()) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = 'All';
                      _selectedAvailability = 'All';
                      _selectedDateRange = 'All Time';
                      _selectedLocation = 'All Locations';
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to browse events page
                    Navigator.of(context).pushNamed('/attendee-all-events');
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Browse Events'),
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
            selectedAvailability: _selectedAvailability,
            selectedDateRange: _selectedDateRange,
            selectedLocation: _selectedLocation,
            categories: _categories,
            onFiltersChanged: (category, availability, dateRange, location) {
              setState(() {
                _selectedCategory = category;
                _selectedAvailability = availability;
                _selectedDateRange = dateRange;
                _selectedLocation = location;
              });
            },
          ),
    );
  }
}
