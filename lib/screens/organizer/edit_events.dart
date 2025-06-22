import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_actions.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_basic_info.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_capacity.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_category.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_datetime.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_header.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_location.dart';
import 'package:megavent/widgets/organizer/events/edit_event/edit_event_poster.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';
import 'package:megavent/data/fake_data.dart';

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
  String? _currentPosterUrl; // Track the current poster URL

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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
    _currentPosterUrl = widget.event.posterUrl; // Initialize current poster URL
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
    setState(() {
      _currentPosterUrl = newUrl;
    });
    // Also update the controller for consistency
    if (newUrl != null) {
      _posterUrlController.text = newUrl;
    } else {
      _posterUrlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: widget.event.name),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
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
              EditEventPoster(
                initialPosterUrl: _currentPosterUrl,
                eventId:
                    widget
                        .event
                        .id, // You'll need to add an id field to your Event model
                eventName: _nameController.text,
                onPosterUrlChanged: _onPosterUrlChanged,
              ),
              const SizedBox(height: 30),
              EditEventActions(
                formKey: _formKey,
                nameController: _nameController,
                onCancel: () => Navigator.pop(context),
                onSave: _saveEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Create updated event data including the new poster URL
      final updatedEventData = {
        'id': widget.event.id, // Assuming your Event model has an id field
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'location': _locationController.text,
        'capacity': int.tryParse(_capacityController.text) ?? 0,
        'posterUrl': _currentPosterUrl, // Use the updated poster URL
      };

      // Here you would typically send this data to your backend
      print('Updated Event Data: $updatedEventData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_nameController.text} has been updated successfully',
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }
}
