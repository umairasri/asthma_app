import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeFacilityName extends StatelessWidget {
  const ChangeFacilityName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Facility Name',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your healthcare facility name. This name will be visible to patients.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateFacilityNameFormKey,
              child: TextFormField(
                controller: controller.facilityName,
                validator: (value) =>
                    TValidator.validateEmptyText('Facility name', value),
                expands: false,
                decoration: const InputDecoration(
                  labelText: 'Facility Name',
                  prefixIcon: Icon(Iconsax.building),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateFacilityName(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
