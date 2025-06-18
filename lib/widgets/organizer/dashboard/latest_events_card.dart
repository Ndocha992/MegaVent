import 'package:flutter/material.dart';
import 'package:megavent/screens/organizer/events_details.dart';
import 'package:megavent/utils/constants.dart';
import 'package:megavent/data/fake_data.dart';
import 'package:megavent/widgets/organizer/events/event_card.dart';

class LatestEventsCard extends StatelessWidget {
  final List<Event> events;

  const LatestEventsCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Events', style: AppConstants.headlineSmall),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/organizer-events');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Adjusted height for compact cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: EventCard(
                  event: event,
                  isCompact: true, // Use compact version
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EventsDetails(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
