import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:iconsax/iconsax.dart';

class AddDependentForm extends StatelessWidget {
  const AddDependentForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DependentController());

    return Form(
      key: controller.dependentFormKey,
      child: Column(
        children: [
          /// Profile Image
          Stack(
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 50,
                  backgroundImage: controller.profileImage.value != null
                      ? FileImage(File(controller.profileImage.value!.path))
                      : null,
                  child: controller.profileImage.value == null
                      ? const Icon(Iconsax.user, size: 50)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Name
          TextFormField(
            controller: controller.name,
            validator: (value) => TValidator.validateEmptyText('Name', value),
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Iconsax.user),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Gender Dropdown
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedGender.value.isEmpty
                  ? null
                  : controller.selectedGender.value,
              onChanged: (value) =>
                  controller.selectedGender.value = value ?? '',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select gender'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Iconsax.user_tag),
              ),
              items: ['Male', 'Female']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Date of Birth
          TextFormField(
            controller: controller.dateOfBirth,
            validator: (value) =>
                TValidator.validateEmptyText('Date of Birth', value),
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Iconsax.calendar),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                controller.selectedDob.value = date;
                controller.dateOfBirth.text =
                    '${date.day}/${date.month}/${date.year}';
              }
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Relation Dropdown
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedRelation.value.isEmpty
                  ? null
                  : controller.selectedRelation.value,
              onChanged: (value) =>
                  controller.selectedRelation.value = value ?? '',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select relation'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Relation',
                prefixIcon: Icon(Iconsax.user_add),
              ),
              items: ['Child', 'Parent', 'Grandparent', 'Spouse', 'Other']
                  .map((relation) => DropdownMenuItem(
                        value: relation,
                        child: Text(relation),
                      ))
                  .toList(),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Daily Medication Usage
          TextFormField(
            controller: controller.dailyMedicationUsage,
            validator: (value) =>
                TValidator.validateEmptyText('Daily Medication Dose', value),
            decoration: const InputDecoration(
              labelText: 'Daily Medication Dose',
              prefixIcon: Icon(Iconsax.clock),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          /// Add Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.addDependent,
              child: const Text('Add Dependent'),
            ),
          ),
        ],
      ),
    );
  }
}
