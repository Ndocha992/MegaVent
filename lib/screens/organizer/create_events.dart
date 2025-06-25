import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/create_event/action_buttons.dart';
import 'package:megavent/widgets/organizer/events/create_event/basic_info_section.dart';
import 'package:megavent/widgets/organizer/events/create_event/capacity_section.dart';
import 'package:megavent/widgets/organizer/events/create_event/category_section.dart';
import 'package:megavent/widgets/organizer/events/create_event/date_time_section.dart';
import 'package:megavent/widgets/organizer/events/create_event/header_widget.dart';
import 'package:megavent/widgets/organizer/events/create_event/location_section.dart';
import 'package:megavent/widgets/organizer/events/create_event/poster_section.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/organizer.dart';

class CreateEvents extends StatefulWidget {
  const CreateEvents({super.key});

  @override
  State<CreateEvents> createState() => _CreateEventsState();
}

class _CreateEventsState extends State<CreateEvents> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentRoute = '/organizer-events';

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String _selectedCategory = 'Technology';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String? _posterUrl;
  bool _isLoading = false;

  late DatabaseService _databaseService;
  List<String> _categories = [];
  Organizer? _currentOrganizer; // Add this to store current organizer

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeCategories();
    _loadCurrentOrganizer(); // Add this to load organizer data
  }

  void _initializeCategories() {
    _categories = _databaseService.getEventCategories();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  // Add this method to load current organizer data
  void _loadCurrentOrganizer() {
    _databaseService.streamCurrentOrganizerData().listen((organizer) {
      if (mounted) {
        setState(() {
          _currentOrganizer = organizer;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: 'Create Events'),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderWidget(),
                  const SizedBox(height: 30),
                  BasicInfoSection(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                  ),
                  const SizedBox(height: 25),
                  CategorySection(
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  DateTimeSection(
                    startDate: _startDate,
                    endDate: _endDate,
                    startTimeController: _startTimeController,
                    endTimeController: _endTimeController,
                    onStartDateChanged: (date) {
                      setState(() {
                        _startDate = date;
                        if (_startDate.isAfter(_endDate)) {
                          _endDate = _startDate.add(const Duration(days: 1));
                        }
                      });
                    },
                    onEndDateChanged: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                    onStartTimeChanged: (time) {
                      setState(() {
                        _startTimeController.text = time;
                      });
                    },
                    onEndTimeChanged: (time) {
                      setState(() {
                        _endTimeController.text = time;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  LocationSection(locationController: _locationController),
                  const SizedBox(height: 25),
                  CapacitySection(capacityController: _capacityController),
                  const SizedBox(height: 25),
                  PosterSection(
                    posterUrl: _posterUrl,
                    onPosterUrlChanged: (url) {
                      setState(() {
                        _posterUrl = url;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  ActionButtons(
                    formKey: _formKey,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    locationController: _locationController,
                    capacityController: _capacityController,
                    posterUrl: _posterUrl,
                    startTimeController: _startTimeController,
                    endTimeController: _endTimeController,
                    isLoading: _isLoading,
                    onClearForm: _clearForm,
                    onCreateEvent: _createEvent,
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: AppConstants.primaryColor.withOpacity(0.1),
              child: const Center(
                child: SpinKitThreeBounce(
                  color: AppConstants.primaryColor,
                  size: 20.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Form'),
          content: const Text('Are you sure you want to clear all fields?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _nameController.clear();
                  _descriptionController.clear();
                  _locationController.clear();
                  _capacityController.clear();
                  _startTimeController.clear();
                  _endTimeController.clear();
                  _selectedCategory =
                      _categories.isNotEmpty ? _categories.first : 'Technology';
                  _startDate = DateTime.now();
                  _endDate = DateTime.now().add(const Duration(days: 1));
                  _posterUrl = null;
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear',
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if organizer data is available
    if (_currentOrganizer == null) {
      _showErrorSnackBar(
        'Unable to load organizer information. Please try again.',
      );
      return;
    }

    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Event name is required');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('Event description is required');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showErrorSnackBar('Event location is required');
      return;
    }

    if (_capacityController.text.trim().isEmpty) {
      _showErrorSnackBar('Event capacity is required');
      return;
    }

    if (_startTimeController.text.trim().isEmpty) {
      _showErrorSnackBar('Start time is required');
      return;
    }

    if (_endTimeController.text.trim().isEmpty) {
      _showErrorSnackBar('End time is required');
      return;
    }

    // Validate capacity
    final capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null || capacity <= 0) {
      _showErrorSnackBar('Please enter a valid capacity');
      return;
    }

    // Validate dates
    if (_startDate.isAfter(_endDate)) {
      _showErrorSnackBar('Start date cannot be after end date');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create event object with organizer name
      final event = Event(
        id: '', // Will be set by the database service
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        posterUrl: _posterUrl ?? '',
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        location: _locationController.text.trim(),
        capacity: capacity,
        registeredCount: 0,
        attendedCount: 0,
        organizerId: '', // Will be set by the database service
        organizerName: _getOrganizerDisplayName(), // Use organizer's name
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Create event in database
      final eventId = await _databaseService.createEvent(event);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_nameController.text.trim()} has been created successfully!',
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back to events list
        Navigator.pop(context, eventId);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to create event: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add this method to get organizer's display name
  String _getOrganizerDisplayName() {
    if (_currentOrganizer == null) return 'Unknown Organizer';

    // Try to get full name first
    final fullName = _currentOrganizer!.fullName.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    } else if (fullName.isNotEmpty) {
      return fullName;
    }

    // Fallback to email or company name
    final email = _currentOrganizer!.email.trim();
    final companyName = _currentOrganizer!.organization?.trim() ?? '';

    if (companyName.isNotEmpty) {
      return companyName;
    } else if (email.isNotEmpty) {
      return email;
    }

    return 'Unknown Organizer';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
