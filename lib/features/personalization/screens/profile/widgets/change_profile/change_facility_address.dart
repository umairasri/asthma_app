import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeFacilityAddress extends StatelessWidget {
  const ChangeFacilityAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Facility Address',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your healthcare facility address. This will help patients locate your facility.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateFacilityAddressFormKey,
              child: TextFormField(
                controller: controller.facilityAddress,
                validator: (value) =>
                    TValidator.validateEmptyText('Address', value),
                expands: false,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Facility Address',
                  prefixIcon: Icon(Iconsax.location),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateFacilityAddress(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
