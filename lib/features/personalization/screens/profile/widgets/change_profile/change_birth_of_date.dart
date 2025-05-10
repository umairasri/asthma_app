import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/update_profile/update_birth_of_date_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeDateOfBirth extends StatelessWidget {
  const ChangeDateOfBirth({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateBirthOfDateController());

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Date of Birth',
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
              'Select your date of birth using the calendar below.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// Warning Text
            Text(
              '⚠️ Make sure your birth date is correct. It might be used for verification and cannot be changed later.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Date Picker Field
            Form(
              key: controller.dobFormKey,
              child: TextFormField(
                controller: controller.dateOfBirth,
                readOnly: true,
                onTap: () => controller.pickDate(context),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select your date of birth'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Iconsax.calendar),
                  suffixIcon: Icon(Iconsax.arrow_circle_down),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateDateOfBirth(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
