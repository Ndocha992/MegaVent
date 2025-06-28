import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_actions.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_basic_info.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_capacity.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_category.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_datetime.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_header.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_location.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_poster.dart';
import 'package:megavent/widgets/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/services/database_service.dart';
import 'package:megavent/models/event.dart';
import 'package:megavent/models/organizer.dart';

class EditEvents extends StatefulWidget {
  final Event event;

  const EditEvents({super.key, required this.event});

  @override
  State<EditEvents> createState() => _EditEventsState();
}

class _EditEventsState extends State<EditEvents> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currentRoute = '/organizer-events';

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _capacityController;
  late TextEditingController _posterUrlController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  late String _selectedCategory;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _currentPosterUrl;
  bool _isLoading = false;

  late DatabaseService _databaseService;
  List<String> _categories = [];
  Organizer? _currentOrganizer;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeControllers();
    _initializeCategories();
    _loadCurrentOrganizer();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _locationController = TextEditingController(text: widget.event.location);
    _capacityController = TextEditingController(
      text: widget.event.capacity.toString(),
    );
    _posterUrlController = TextEditingController(text: widget.event.posterUrl);
    _startTimeController = TextEditingController(text: widget.event.startTime);
    _endTimeController = TextEditingController(text: widget.event.endTime);

    _selectedCategory = widget.event.category;
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
    // Initialize with the current poster URL from the event
    _currentPosterUrl =
        widget.event.posterUrl.isNotEmpty ? widget.event.posterUrl : null;

    print('Initialized with poster URL: $_currentPosterUrl');
  }

  void _initializeCategories() {
    _categories = _databaseService.getEventCategories();
    // Ensure current category exists in the list
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
  }

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
    _posterUrlController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _onPosterUrlChanged(String? newUrl) {
    print('Poster URL callback received: $newUrl');
    setState(() {
      _currentPosterUrl = newUrl;
    });

    // Also update the controller for consistency
    if (newUrl != null && newUrl.isNotEmpty) {
      _posterUrlController.text = newUrl;
    } else {
      _posterUrlController.clear();
    }

    print('State updated - Current poster URL: $_currentPosterUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: widget.event.name),
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
                  EditEventHeader(),
                  const SizedBox(height: 30),
                  EditEventBasicInfo(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                  ),
                  const SizedBox(height: 25),
                  EditEventCategory(
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  EditEventDateTime(
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
                  EditEventLocation(locationController: _locationController),
                  const SizedBox(height: 25),
                  EditEventCapacity(capacityController: _capacityController),
                  const SizedBox(height: 25),
                  // Remove the key since we're managing state properly now
                  EditEventPoster(
                    initialPosterUrl: _currentPosterUrl,
                    eventId: widget.event.id,
                    eventName: _nameController.text,
                    onPosterUrlChanged: _onPosterUrlChanged,
                  ),
                  const SizedBox(height: 30),
                  EditEventActions(
                    formKey: _formKey,
                    nameController: _nameController,
                    isLoading: _isLoading,
                    onCancel: () => Navigator.pop(context),
                    onSave: _saveEvent,
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isLoading)
            const Center(
              child: SpinKitThreeBounce(
                color: AppConstants.primaryColor,
                size: 20.0,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveEvent() async {
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

    // Validate that new capacity is not less than current registered count
    if (capacity < widget.event.registeredCount) {
      _showErrorSnackBar(
        'Capacity cannot be less than current registered attendees (${widget.event.registeredCount})',
      );
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
      // Use the current poster URL from state - this will be the updated URL if changed
      final finalPosterUrl = _currentPosterUrl ?? '';

      print('Saving event with poster URL: $finalPosterUrl');

      // Create updated event object
      final updatedEvent = widget.event.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        posterUrl: finalPosterUrl,
        startDate: _startDate,
        endDate: _endDate,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        location: _locationController.text.trim(),
        capacity: capacity,
        organizerName: _getOrganizerDisplayName(),
        updatedAt: DateTime.now(),
      );

      // Update event in database
      await _databaseService.updateEvent(updatedEvent);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_nameController.text.trim()} has been updated successfully!',
            ),
            backgroundColor: AppConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate back with updated event
        Navigator.pop(context, updatedEvent);
      }
    } catch (e) {
      print('Error saving event: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to update event: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _getOrganizerDisplayName() {
    if (_currentOrganizer == null) return widget.event.organizerName;

    // Try to get full name first
    final fullName = _currentOrganizer!.fullName.trim();

    if (fullName.isNotEmpty) {
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

    return widget
        .event
        .organizerName; // Keep original if nothing else is available
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
