import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeFacilityContact extends StatelessWidget {
  const ChangeFacilityContact({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Contact Number',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your healthcare facility contact number. This will be used for patient communications.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateFacilityContactFormKey,
              child: TextFormField(
                controller: controller.facilityContact,
                validator: (value) => TValidator.validatePhoneNumber(value),
                expands: false,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Iconsax.call),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateFacilityContact(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
