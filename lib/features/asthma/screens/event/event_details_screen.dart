import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:asthma_app/common/widgets/buttons/custom_button.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/features/participants/controllers/participant_controller.dart';
import 'package:asthma_app/features/events/controllers/event_controller.dart';
import 'package:asthma_app/features/asthma/screens/event/widgets/select_dependent_dialog.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/asthma/screens/event/widgets/participant_selection_card.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;
  final String healthcareId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.healthcareId,
  });

  @override
  Widget build(BuildContext context) {
    final eventController = Get.put(EventController());
    final participantController = Get.put(ParticipantController());
    final userController = Get.put(PatientController());
    final dependentController = Get.put(DependentController());
    final selectedDependentController = Get.put(SelectedDependentController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                    title: Text(
                      'Event Details',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: TColors.white),
                    ),
                    showBackArrow: true,
                    leadingIcon: Iconsax.arrow_left,
                    leadingOnPressed: () => Get.back(),
                    iconColor: TColors.white,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// -- Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  TRoundedContainer(
                    height: 200,
                    backgroundColor: TColors.light,
                    child: Obx(() {
                      final event = eventController.events
                          .firstWhereOrNull((e) => e.eventId == eventId);
                      if (event?.image != null) {
                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(TSizes.borderRadiusLg),
                          child: Image.network(
                            event!.image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }
                      return const Center(
                        child: Icon(
                          Icons.event,
                          size: 50,
                          color: TColors.darkGrey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Event Title and Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Obx(() {
                          final event = eventController.events
                              .firstWhereOrNull((e) => e.eventId == eventId);
                          return Text(
                            event?.eventName ?? 'Loading...',
                            style: Theme.of(context).textTheme.headlineSmall,
                          );
                        }),
                      ),
                      Obx(() {
                        final event = eventController.events
                            .firstWhereOrNull((e) => e.eventId == eventId);
                        final currentParticipants =
                            event?.currentParticipants ?? 0;
                        final isFull = currentParticipants >=
                            (event?.numberOfParticipant ?? 0);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.sm,
                            vertical: TSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isFull
                                ? TColors.error.withOpacity(0.1)
                                : TColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(TSizes.borderRadiusLg),
                          ),
                          child: Text(
                            isFull
                                ? 'Full'
                                : '${(event?.numberOfParticipant ?? 0) - currentParticipants} slots',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.apply(
                                  color:
                                      isFull ? TColors.error : TColors.primary,
                                ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Event Details Container
                  TRoundedContainer(
                    padding: const EdgeInsets.all(TSizes.md),
                    backgroundColor: TColors.white,
                    showBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date and Time
                        Obx(() {
                          final event = eventController.events
                              .firstWhereOrNull((e) => e.eventId == eventId);
                          return _buildDetailRow(
                            context,
                            icon: Icons.calendar_today,
                            title: 'Date & Time',
                            value:
                                '${event?.date ?? ''} at ${event?.time ?? ''}',
                          );
                        }),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Location
                        Obx(() {
                          final event = eventController.events
                              .firstWhereOrNull((e) => e.eventId == eventId);
                          return _buildDetailRow(
                            context,
                            icon: Icons.location_on,
                            title: 'Location',
                            value: event?.location ?? '',
                          );
                        }),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Description
                        Text(
                          'About the Event',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        Obx(() {
                          final event = eventController.events
                              .firstWhereOrNull((e) => e.eventId == eventId);
                          return Text(
                            event?.details ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Join Button
                  Obx(() {
                    final event = eventController.events
                        .firstWhereOrNull((e) => e.eventId == eventId);
                    final currentParticipants = event?.currentParticipants ?? 0;
                    final isFull = currentParticipants >=
                        (event?.numberOfParticipant ?? 0);

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () => _showSelectDependentPopup(
                                  context,
                                  userController,
                                  dependentController,
                                  selectedDependentController,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFull ? TColors.grey : TColors.primary,
                          foregroundColor: TColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(TSizes.borderRadiusLg),
                          ),
                          elevation: isFull ? 0 : 2,
                        ),
                        child: Text(
                          isFull ? 'Event Full' : 'Join Now',
                          style: Theme.of(context).textTheme.titleMedium?.apply(
                                color: TColors.white,
                              ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectDependentPopup(
    BuildContext context,
    PatientController userController,
    DependentController dependentController,
    SelectedDependentController selectedDependentController,
  ) {
    final eventController = Get.find<EventController>();
    final participantController = Get.find<ParticipantController>();

    // Reset the selected dependent before showing the popup
    selectedDependentController.selectedDependent.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => SelectDependentDialog(
          userController: userController,
          dependentController: dependentController,
          selectedDependentController: selectedDependentController,
          onParticipantSelected: (selectedParticipant) async {
            if (selectedParticipant != null) {
              // Close the bottom sheet first
              Navigator.pop(context);

              // Add a small delay to ensure the bottom sheet is closed
              await Future.delayed(const Duration(milliseconds: 300));

              // Then handle the join event process
              await _handleJoinEvent(
                eventController,
                participantController,
                selectedDependentController,
                eventId,
                participantController.participants
                    .where((p) => p.eventId == eventId)
                    .length,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _handleJoinEvent(
    EventController eventController,
    ParticipantController participantController,
    SelectedDependentController selectedDependentController,
    String eventId,
    int currentParticipants,
  ) async {
    try {
      final selectedParticipant =
          selectedDependentController.selectedDependent.value;

      // Double check if participant is selected
      if (selectedParticipant == null) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Please select a participant',
        );
        return;
      }

      // Check if participant already exists
      final existingParticipant =
          participantController.participants.firstWhereOrNull(
        (p) => p.eventId == eventId && p.dependentId == selectedParticipant.id,
      );

      if (existingParticipant != null) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message: 'This participant has already joined the event',
        );
        return;
      }

      // Show loading indicator
      TFullScreenLoader.openLoadingDialog(
        'Joining event...',
        TImages.docerAnimation,
      );

      // Add participant
      await participantController.addParticipant(
        dependentId: selectedParticipant.id,
        eventId: eventId,
      );

      // Update participant count
      await eventController.updateParticipantCount(
        eventId,
        currentParticipants + 1,
      );

      // Remove loader
      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Successfully joined the event',
      );

      // Clear selection
      selectedDependentController.selectedDependent.value = null;
    } catch (e) {
      // Remove loader if it's showing
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to join event: $e',
      );
    }
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
            ),
            child: Icon(icon, size: 20, color: TColors.primary),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.apply(
                        color: TColors.darkerGrey,
                      ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems / 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.apply(
                        color: TColors.dark,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
