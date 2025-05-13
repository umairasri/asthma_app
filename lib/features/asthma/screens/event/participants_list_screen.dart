import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/features/participants/controllers/participant_controller.dart';
import 'package:asthma_app/features/events/controllers/event_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/utils/popups/loaders.dart';

class ParticipantsListScreen extends StatefulWidget {
  final String eventId;
  final String healthcareId;

  const ParticipantsListScreen({
    super.key,
    required this.eventId,
    required this.healthcareId,
  });

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  final participantController = Get.put(ParticipantController());
  final eventController = Get.find<EventController>();
  final dependentController = Get.find<DependentController>();
  final patientController = Get.find<PatientController>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Fetch participants for this event
      await participantController.getParticipantsByEvent(widget.eventId);
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load participants: $e',
      );
    }
  }

  Widget _buildParticipantInfo(String participantId) {
    // First check if it's a dependent
    final dependent = dependentController.dependents
        .firstWhereOrNull((d) => d.id == participantId);

    if (dependent != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dependent.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Dependent',
            style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: TColors.darkerGrey,
                ),
          ),
        ],
      );
    }

    // If not a dependent, check if it's a patient
    final patient = patientController.user.value;
    if (patient.id == participantId) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            patient.fullName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Patient',
            style: Theme.of(context).textTheme.bodySmall?.apply(
                  color: TColors.darkerGrey,
                ),
          ),
        ],
      );
    }

    // If neither found, show unknown
    return Text(
      'Unknown Participant',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  String _getParticipantInitial(String participantId) {
    // First check if it's a dependent
    final dependent = dependentController.dependents
        .firstWhereOrNull((d) => d.id == participantId);

    if (dependent != null) {
      return dependent.name.substring(0, 1).toUpperCase();
    }

    // If not a dependent, check if it's a patient
    final patient = patientController.user.value;
    if (patient.id == participantId) {
      return patient.firstName.substring(0, 1).toUpperCase();
    }

    // If neither found, return question mark
    return '?';
  }

  @override
  Widget build(BuildContext context) {
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
                      'Event Participants',
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
                  // Event Info Card
                  Obx(() {
                    final event = eventController.events
                        .firstWhereOrNull((e) => e.eventId == widget.eventId);
                    return TRoundedContainer(
                      padding: const EdgeInsets.all(TSizes.md),
                      backgroundColor: TColors.white,
                      showBorder: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event?.eventName ?? 'Loading...',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems / 2),
                          Text(
                            '${event?.date ?? ''} at ${event?.time ?? ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Participants List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Participants List',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Obx(() {
                        final participants = participantController.participants
                            .where((p) => p.eventId == widget.eventId)
                            .toList();
                        return Text(
                          '${participants.length} participants',
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                                color: TColors.darkerGrey,
                              ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() {
                    if (participantController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final participants = participantController.participants
                        .where((p) => p.eventId == widget.eventId)
                        .toList();

                    if (participants.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Text(
                              'No participants yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: TSizes.spaceBtwItems),
                      itemBuilder: (context, index) {
                        final participant = participants[index];

                        return TRoundedContainer(
                          padding: const EdgeInsets.all(TSizes.md),
                          backgroundColor: TColors.white,
                          showBorder: true,
                          child: Row(
                            children: [
                              // Profile Picture
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    TColors.primary.withOpacity(0.1),
                                child: Text(
                                  _getParticipantInitial(
                                      participant.dependentId),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.apply(color: TColors.primary),
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                              // Participant Info
                              Expanded(
                                child: _buildParticipantInfo(
                                    participant.dependentId),
                              ),
                              // Join Date
                              Text(
                                'Joined\n${_formatDate(participant.dateJoin)}',
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
