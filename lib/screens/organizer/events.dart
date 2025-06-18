import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/create_events.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/widgets/organizer/events/event_card.dart';
import 'package:megavent/widgets/organizer/events/event_filters.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentRoute = '/organizer-events';

  late TabController _tabController;
  String _selectedCategory = 'All';
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

  List<Event> get _filteredEvents {
    List<Event> events = FakeData.events;

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
      case 2: // Past
        events =
            events.where((event) => event.startDate.isBefore(now)).toList();
        break;
    }

    return events;
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
          _buildHeader(),
          _buildTabBar(),
          _buildSearchAndFilters(),
          Expanded(child: _buildEventsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const CreateEvents()));
        },
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                      '${FakeData.events.length} Events',
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
        FakeData.events
            .where((event) => event.startDate.isAfter(DateTime.now()))
            .length;
    final pastCount =
        FakeData.events
            .where((event) => event.startDate.isBefore(DateTime.now()))
            .length;

    return Row(
      children: [
        _buildStatCard('Upcoming', upcomingCount, AppConstants.successColor),
        const SizedBox(width: 12),
        _buildStatCard('Past', pastCount, AppConstants.textSecondaryColor),
        const SizedBox(width: 12),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: filteredEvents[index],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EventsDetails(event: filteredEvents[index]),
                  ),
                );
              },
            ),
          );
        },
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
              'No events found',
              style: AppConstants.titleLarge.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : 'Start by creating your first event',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateEvents()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => EventFilters(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() => _selectedCategory = category);
              Navigator.pop(context);
            },
          ),
    );
  }
}
