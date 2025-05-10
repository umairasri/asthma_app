import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';
import 'package:asthma_app/features/asthma/screens/event/event_details_screen.dart';
import 'package:asthma_app/features/events/controllers/event_controller.dart';
import 'package:asthma_app/features/participants/controllers/participant_controller.dart';

class EventListWidget extends StatefulWidget {
  const EventListWidget({super.key});

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  final eventController = Get.put(EventController());
  final participantController = Get.put(ParticipantController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    try {
      await eventController.getAllEvents();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events: $e');
    }
  }

  List<dynamic> _filterEvents() {
    // First get upcoming events
    final upcomingEvents = eventController.getUpcomingEvents();

    // Then apply search filter if there's a search query
    if (_searchQuery.isEmpty) {
      return upcomingEvents;
    }

    return upcomingEvents.where((event) {
      return event.eventName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.details.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          TSectionHeading(
            title: 'Upcoming Events',
            showActionButton: false,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Search Bar
          TRoundedContainer(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
            backgroundColor: TColors.light,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Event List
          Obx(() {
            if (eventController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final filteredEvents = _filterEvents();

            if (filteredEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 50,
                      color: TColors.darkGrey,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No upcoming events available'
                          : 'No events found matching "$_searchQuery"',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                final currentParticipants = participantController.participants
                    .where((p) => p.eventId == event.eventId)
                    .length;
                final isFull = currentParticipants >= event.numberOfParticipant;
                final availableSlots =
                    event.numberOfParticipant - currentParticipants;

                return GestureDetector(
                  onTap: () => Get.to(() => EventDetailsScreen(
                        eventId: event.eventId,
                        healthcareId: event.healthcareId,
                      )),
                  child: TRoundedContainer(
                    padding: const EdgeInsets.all(TSizes.md),
                    margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    backgroundColor: TColors.white,
                    showBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image
                        TRoundedContainer(
                          height: 160,
                          backgroundColor: TColors.light,
                          child: event.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      TSizes.borderRadiusLg),
                                  child: Image.network(
                                    event.image!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.event,
                                    size: 40,
                                    color: TColors.darkGrey,
                                  ),
                                ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Event Title and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.eventName,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.sm,
                                vertical: TSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: isFull
                                    ? TColors.error.withOpacity(0.1)
                                    : TColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    TSizes.borderRadiusLg),
                              ),
                              child: Text(
                                isFull ? 'Full' : '$availableSlots slots',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.apply(
                                      color: isFull
                                          ? TColors.error
                                          : TColors.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        // Event Date and Time
                        Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: TColors.light,
                            borderRadius:
                                BorderRadius.circular(TSizes.borderRadiusLg),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(TSizes.xs),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      TSizes.borderRadiusLg),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: TColors.primary,
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Text(
                                event.date,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                              Container(
                                padding: const EdgeInsets.all(TSizes.xs),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      TSizes.borderRadiusLg),
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: TColors.primary,
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Text(
                                event.time,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        // Event Location
                        Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: TColors.light,
                            borderRadius:
                                BorderRadius.circular(TSizes.borderRadiusLg),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(TSizes.xs),
                                decoration: BoxDecoration(
                                  color: TColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                      TSizes.borderRadiusLg),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: TColors.primary,
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),

                        // Event Description
                        Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: TColors.light,
                            borderRadius:
                                BorderRadius.circular(TSizes.borderRadiusLg),
                          ),
                          child: Text(
                            event.details,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
