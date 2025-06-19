import 'package:flutter/material.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/widgets/organizer/create_event/action_buttons.dart';
import 'package:megavent/widgets/organizer/create_event/basic_info_section.dart';
import 'package:megavent/widgets/organizer/create_event/capacity_section.dart';
import 'package:megavent/widgets/organizer/create_event/category_section.dart';
import 'package:megavent/widgets/organizer/create_event/date_time_section.dart';
import 'package:megavent/widgets/organizer/create_event/header_widget.dart';
import 'package:megavent/widgets/organizer/create_event/location_section.dart';
import 'package:megavent/widgets/organizer/create_event/poster_section.dart';
import 'package:megavent/widgets/organizer/nested_app_bar.dart';
import 'package:megavent/widgets/organizer/sidebar.dart';

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
  final TextEditingController _posterUrlController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String _selectedCategory = 'Technology';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppConstants.backgroundColor,
      appBar: NestedScreenAppBar(screenTitle: 'Create Events'),
      drawer: OrganizerSidebar(currentRoute: currentRoute),
      body: SingleChildScrollView(
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
                posterUrlController: _posterUrlController,
                onPosterUrlChanged: () {
                  setState(() {});
                },
              ),
              const SizedBox(height: 30),
              ActionButtons(
                formKey: _formKey,
                nameController: _nameController,
                descriptionController: _descriptionController,
                locationController: _locationController,
                capacityController: _capacityController,
                posterUrlController: _posterUrlController,
                startTimeController: _startTimeController,
                endTimeController: _endTimeController,
                onClearForm: _clearForm,
                onCreateEvent: _createEvent,
              ),
            ],
          ),
        ),
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
                  _posterUrlController.clear();
                  _startTimeController.clear();
                  _endTimeController.clear();
                  _selectedCategory = 'Technology';
                  _startDate = DateTime.now();
                  _endDate = DateTime.now().add(const Duration(days: 1));
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

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_nameController.text} has been created successfully',
          ),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back or to events list
      Navigator.pop(context);
    }
  }
}
