import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeDailyMedication extends StatelessWidget {
  const ChangeDailyMedication({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Daily Medication',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your daily medication usage. This information helps in tracking your asthma management.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateDailyMedicationFormKey,
              child: TextFormField(
                controller: controller.dailyMedication,
                validator: (value) =>
                    TValidator.validateEmptyText('Daily medication', value),
                expands: false,
                decoration: const InputDecoration(
                  labelText: 'Daily Medication Usage',
                  prefixIcon: Icon(Iconsax.health),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateDailyMedication(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
