import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';
import 'package:asthma_app/features/asthma/screens/event/event_details_screen.dart';
import 'package:asthma_app/features/events/controllers/event_controller.dart';
import 'package:asthma_app/features/participants/controllers/participant_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventsHistoryScreen extends StatefulWidget {
  const EventsHistoryScreen({super.key});

  @override
  State<EventsHistoryScreen> createState() => _EventsHistoryScreenState();
}

class _EventsHistoryScreenState extends State<EventsHistoryScreen> {
  final eventController = Get.find<EventController>();
  final participantController = Get.find<ParticipantController>();
  final selectedDependentController = Get.find<SelectedDependentController>();
  final patientController = Get.find<PatientController>();
  final dependentController = Get.find<DependentController>();

  // List to hold all possible selections (patient + dependents)
  final RxList<DependentModel> allSelections = <DependentModel>[].obs;
  // Currently selected patient/dependent
  final Rx<DependentModel?> selectedPerson = Rx<DependentModel?>(null);
  // Filter for upcoming/past events
  final RxBool showUpcomingEvents = true.obs;

  @override
  void initState() {
    super.initState();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    // Add the patient as the first option
    allSelections.add(DependentModel(
      id: patientController.user.value.id,
      userId: patientController.user.value.id,
      name: patientController.user.value.username,
      gender: patientController.user.value.gender,
      dateOfBirth: patientController.user.value.dateOfBirth,
      profilePicture: patientController.user.value.profilePicture,
      relation: 'Main Account',
      dailyMedicationUsage: patientController.user.value.dailyMedicationUsage,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    ));

    // Load dependents
    await dependentController.fetchUserDependents();
    allSelections.addAll(dependentController.dependents);

    // Set initial selection to the currently selected dependent or patient
    final currentSelection =
        selectedDependentController.selectedDependent.value;
    if (currentSelection != null) {
      selectedPerson.value = allSelections.firstWhereOrNull(
        (p) => p.id == currentSelection.id,
      );
    }
    if (selectedPerson.value == null && allSelections.isNotEmpty) {
      selectedPerson.value = allSelections.first;
    }

    // Load all events and participants
    await eventController.getAllEvents();
    await participantController.fetchParticipants();
  }

  bool _isEventPast(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return false;

      final eventDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      // Consider an event past if it's before the current date (ignoring time)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

      return eventDay.isBefore(today);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        iconTheme: const IconThemeData(color: TColors.dark),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            TSectionHeading(
              title: 'Select a user',
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Patient/Dependent Selection Dropdown
            Obx(() {
              if (allSelections.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return TRoundedContainer(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                backgroundColor: TColors.light,
                child: DropdownButton<DependentModel>(
                  value: selectedPerson.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: allSelections.map((person) {
                    return DropdownMenuItem<DependentModel>(
                      value: person,
                      child: Text(person.name ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (DependentModel? newValue) {
                    if (newValue != null) {
                      selectedPerson.value = newValue;
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: TSizes.spaceBtwItems * 2),

            // Event Filter Segmented Control
            TRoundedContainer(
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: TColors.light,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildFilterButton(
                          'Upcoming',
                          showUpcomingEvents.value,
                          () => showUpcomingEvents.value = true,
                        )),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Obx(() => _buildFilterButton(
                          'Past',
                          !showUpcomingEvents.value,
                          () => showUpcomingEvents.value = false,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Expanded(
              child: Obx(() {
                if (eventController.isLoading.value ||
                    participantController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final String selectedPersonId = selectedPerson.value?.id ?? '';

                // Get all participant records for the selected person
                final joinedEvents =
                    participantController.participants.where((p) {
                  return p.dependentId == selectedPersonId;
                }).toList();

                // Get all events that the selected person has joined
                final allEvents = showUpcomingEvents.value
                    ? eventController.getUpcomingEvents()
                    : eventController.getPastEvents();

                final events = allEvents.where((event) {
                  return joinedEvents.any((p) => p.eventId == event.eventId);
                }).toList();

                // Sort events by date (most recent first for past events, soonest first for upcoming)
                events.sort((a, b) {
                  final dateA = _parseDate(a.date);
                  final dateB = _parseDate(b.date);
                  return showUpcomingEvents.value
                      ? dateA.compareTo(dateB) // Soonest first for upcoming
                      : dateB.compareTo(dateA); // Most recent first for past
                });

                if (events.isEmpty) {
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
                          'No ${showUpcomingEvents.value ? "upcoming" : "past"} events found for ${selectedPerson.value?.name ?? "selected person"}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => EventDetailsScreen(
                            eventId: event.eventId,
                            healthcareId: event.healthcareId,
                          )),
                      child: TRoundedContainer(
                        padding: const EdgeInsets.all(TSizes.md),
                        margin:
                            const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                        backgroundColor: TColors.white,
                        showBorder: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Image
                            TRoundedContainer(
                              height: 120,
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
                            // Event Title
                            Text(
                              event.eventName,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            // Event Date and Time
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: TColors.primary),
                                const SizedBox(width: 8),
                                Text(event.date,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time,
                                    size: 16, color: TColors.primary),
                                const SizedBox(width: 8),
                                Text(event.time,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems / 2),
                            // Event Location
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: TColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.apply(
                  color: isSelected ? TColors.white : TColors.dark,
                ),
          ),
        ),
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return DateTime.now();
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}
