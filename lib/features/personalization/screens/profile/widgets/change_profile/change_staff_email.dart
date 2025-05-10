import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeStaffEmail extends StatelessWidget {
  const ChangeStaffEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Staff Email',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update the email address of the staff member representing your healthcare facility.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateStaffEmailFormKey,
              child: TextFormField(
                controller: controller.staffEmail,
                validator: (value) => TValidator.validateEmail(value),
                expands: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Staff Email',
                  prefixIcon: Icon(Iconsax.message),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateStaffEmail(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
