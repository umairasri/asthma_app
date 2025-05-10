import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/asthma/models/symptom_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/logger.dart';

class TodaySymptomCard extends StatelessWidget {
  const TodaySymptomCard({super.key});

  @override
  Widget build(BuildContext context) {
    final SymptomController controller = Get.find<SymptomController>();
    final PatientController userController = Get.find<PatientController>();
    final SelectedDependentController selectedDependentController =
        Get.find<SelectedDependentController>();

    return Obx(() {
      if (controller.loadingSymptoms.value) {
        return const TShimmerEffect(width: 80, height: 15);
      }

      // Get today's date formatted the same way as stored in DB
      final String todayDate = SymptomModel.formatDate(DateTime.now());
      final String currentUserId =
          selectedDependentController.getSelectionUserId();

      TLogger.debug(
          'Fetching symptoms for date: $todayDate and user/dependent: $currentUserId');

      // Filter symptoms for today
      final List<SymptomModel> todaySymptoms = controller.symptoms
          .where((s) => s.date == todayDate)
          .where((s) => s.userId == currentUserId)
          .toList();

      TLogger.debug('Found ${todaySymptoms.length} symptoms for today');

      if (todaySymptoms.isEmpty) {
        return const Center(
          child: Text(
            'No symptoms recorded for today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        );
      }

      return Column(
        children: List.generate(todaySymptoms.length, (index) {
          final symptom = todaySymptoms[index];
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(TImages.coughIcon,
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Symptoms',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                symptom.time,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(
                                  height: TSizes.spaceBtwInputFields),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: symptom.symptom.map((sym) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sym['name'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              if (index != todaySymptoms.length - 1)
                const SizedBox(height: 16), // Space between cards
            ],
          );
        }),
      );
    });
  }
}

/// To use this file in main.dart:
/// Replace the body of Scaffold with: TodaySymptomCard()
/// Make sure to call SymptomController.instance.fetchSymptoms() beforehand
