import 'package:flutter/material.dart';
import 'package:megavent/widgets/organizer/edit_event/custom_text_field.dart';
import 'package:megavent/widgets/organizer/edit_event/date_field.dart';
import 'package:megavent/widgets/organizer/edit_event/section_container.dart';

class EditEventDateTime extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(String) onStartTimeChanged;
  final Function(String) onEndTimeChanged;

  const EditEventDateTime({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.startTimeController,
    required this.endTimeController,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: 'Date & Time',
      icon: Icons.schedule_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: DateField(
                label: 'Start Date',
                date: startDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DateField(
                label: 'End Date',
                date: endDate,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: startTimeController,
                label: 'Start Time',
                hint: 'e.g., 10:00 AM',
                readOnly: true,
                onTap: () => _selectTime(context, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: endTimeController,
                label: 'End Time',
                hint: 'e.g., 08:00 PM',
                readOnly: true,
                onTap: () => _selectTime(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStartDate) {
        onStartDateChanged(picked);
      } else {
        onEndDateChanged(picked);
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final String formattedTime = picked.format(context);
      if (isStartTime) {
        onStartTimeChanged(formattedTime);
      } else {
        onEndTimeChanged(formattedTime);
      }
    }
  }
}