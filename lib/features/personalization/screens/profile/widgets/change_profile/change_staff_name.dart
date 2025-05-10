import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeStaffName extends StatelessWidget {
  const ChangeStaffName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Staff Name',
            style: Theme.of(context).textTheme.headlineSmall),
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update the name of the staff member representing your healthcare facility.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            Form(
              key: controller.updateStaffNameFormKey,
              child: TextFormField(
                controller: controller.staffName,
                validator: (value) =>
                    TValidator.validateEmptyText('Staff name', value),
                expands: false,
                decoration: const InputDecoration(
                  labelText: 'Staff Name',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateStaffName(),
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
