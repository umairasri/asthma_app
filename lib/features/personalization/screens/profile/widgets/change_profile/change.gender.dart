import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/update_profile/update_gender_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeGender extends StatelessWidget {
  const ChangeGender({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateGenderController());

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Gender',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Info Text
            Text(
              'Select your gender. This information may be used to personalize your experience.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Warning Text
            Text(
              '⚠️ Please note: Once your gender is submitted, it cannot be changed later. Make sure to choose carefully.',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Dropdown Form
            Form(
              key: controller.genderFormKey,
              child: DropdownButtonFormField<String>(
                value: controller.selectedGender.value.isNotEmpty
                    ? controller.selectedGender.value
                    : null,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedGender.value = value;
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select gender'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Iconsax.user_tag),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateGender(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
