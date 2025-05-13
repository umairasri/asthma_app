import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/utils/logger.dart';
import 'event_form.dart';
import 'package:asthma_app/features/asthma/screens/event/event_details_screen.dart';

class HealthcareEventsList extends StatefulWidget {
  final String healthcareId;
  final String searchQuery;
  final String selectedFilter;

  const HealthcareEventsList({
    Key? key,
    required this.healthcareId,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  }) : super(key: key);

  @override
  State<HealthcareEventsList> createState() => _HealthcareEventsListState();
}

class _HealthcareEventsListState extends State<HealthcareEventsList> {
  final EventController _eventController = Get.find<EventController>();
  final RxList<EventModel> _filteredEvents = <EventModel>[].obs;

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure proper widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  @override
  void didUpdateWidget(HealthcareEventsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedFilter != widget.selectedFilter) {
      _filterEvents();
    }
  }

  Future<void> _loadEvents() async {
    try {
      await _eventController.getEventsByHealthcareId(widget.healthcareId);
      _filterEvents();
    } catch (e) {
      TLogger.error('Failed to load events: $e');
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to load events');
    }
  }

  void _filterEvents() {
    if (_eventController.events.isEmpty) {
      _filteredEvents.clear();
      return;
    }

    final now = DateTime.now();
    final filtered = _eventController.events.where((event) {
      // Search filter
      final matchesSearch = widget.searchQuery.isEmpty ||
          event.eventName
              .toLowerCase()
              .contains(widget.searchQuery.toLowerCase());

      // Date filter
      final eventDate = _parseDate(event.date);
      final matchesDateFilter = widget.selectedFilter == 'All' ||
          (widget.selectedFilter == 'Upcoming' && eventDate.isAfter(now)) ||
          (widget.selectedFilter == 'Past' && eventDate.isBefore(now));

      return matchesSearch && matchesDateFilter;
    }).toList();

    _filteredEvents.value = filtered;
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  bool _isFutureEvent(EventModel event) {
    final eventDate = _parseDate(event.date);
    return eventDate.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_eventController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_filteredEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.selectedFilter == 'Upcoming'
                    ? Icons.event_available
                    : Icons.event_busy,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                widget.selectedFilter == 'Upcoming'
                    ? 'No upcoming events'
                    : 'No past events',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                'Create a new event to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(
          top: TSizes.defaultSpace,
          bottom: 80, // Space for FAB
        ),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_filteredEvents[index]);
        },
      );
    });
  }

  Widget _buildEventCard(EventModel event) {
    final isFutureEvent = _isFutureEvent(event);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: TSizes.defaultSpace,
        vertical: TSizes.spaceBtwItems / 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
      ),
      child: InkWell(
        onTap: isFutureEvent
            ? () {
                Get.to(() => EventDetailsScreen(
                      eventId: event.eventId,
                      healthcareId: widget.healthcareId,
                      isHealthcareUser: true,
                    ));
              }
            : () {
                TLoaders.infoSnackBar(
                  title: 'Past Event',
                  message: 'Past events cannot be edited',
                );
              },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image
                if (event.image != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(TSizes.cardRadiusLg)),
                    child: Image.network(
                      event.image!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                // Event Details
                Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.eventName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isFutureEvent ? null : Colors.grey,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isFutureEvent
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusLg),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isFutureEvent)
                                  const Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                if (!isFutureEvent) const SizedBox(width: 4),
                                Text(
                                  isFutureEvent ? 'Upcoming' : 'Past',
                                  style: TextStyle(
                                    color: isFutureEvent
                                        ? Colors.green
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color:
                                isFutureEvent ? TColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.date,
                            style: TextStyle(
                              color: isFutureEvent ? null : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color:
                                isFutureEvent ? TColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.time,
                            style: TextStyle(
                              color: isFutureEvent ? null : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color:
                                isFutureEvent ? TColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isFutureEvent ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems / 2),

                      // Participants
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color:
                                isFutureEvent ? TColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event.numberOfParticipant} participants',
                            style: TextStyle(
                              color: isFutureEvent ? null : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Lock overlay for past events
            if (!isFutureEvent)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
