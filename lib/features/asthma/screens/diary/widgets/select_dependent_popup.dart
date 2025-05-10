import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectDependentPopup extends StatelessWidget {
  const SelectDependentPopup({
    super.key,
    required this.dependentController,
    required this.selectedDependentController,
    required this.userController,
  });

  final DependentController dependentController;
  final SelectedDependentController selectedDependentController;
  final PatientController userController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Patient / Dependent',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // User (Patient) Option
          _buildSelectionCard(
            context,
            isSelected:
                selectedDependentController.selectionType.value == 'user',
            onTap: () {
              selectedDependentController.selectUser();
              Navigator.pop(context);
            },
            image: userController.user.value.profilePicture.isNotEmpty
                ? userController.user.value.profilePicture
                : TImages.user,
            name: userController.user.value.username,
            gender: userController.user.value.gender,
            age: _calculateAge(userController.user.value.dateOfBirth),
            dailyMedicationUsage:
                userController.user.value.dailyMedicationUsage,
          ),

          // Dependents List
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dependentController.dependents.length,
              itemBuilder: (context, index) {
                final dependent = dependentController.dependents[index];
                return _buildSelectionCard(
                  context,
                  isSelected: selectedDependentController.selectionType.value ==
                          'dependent' &&
                      selectedDependentController.selectedDependent.value?.id ==
                          dependent.id,
                  onTap: () {
                    selectedDependentController.selectDependent(dependent);
                    Navigator.pop(context);
                  },
                  image: dependent.profilePicture.isNotEmpty
                      ? dependent.profilePicture
                      : TImages.user,
                  name: dependent.name ?? 'Unknown',
                  gender: dependent.gender ?? '',
                  age: _calculateAge(dependent.dateOfBirth ?? ''),
                  dailyMedicationUsage: dependent.dailyMedicationUsage ?? '0',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required bool isSelected,
    required VoidCallback onTap,
    required String image,
    required String name,
    required String gender,
    required String age,
    required String dailyMedicationUsage,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      color: isSelected ? TColors.primary.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              // Profile Image
              TCircularImage(
                image: image,
                width: 50,
                height: 50,
                padding: 0,
                isNetworkImage: image != TImages.user,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TSizes.xs),
                    Row(
                      children: [
                        Icon(
                          gender.toLowerCase() == 'male'
                              ? Icons.male
                              : gender.toLowerCase() == 'female'
                                  ? Icons.female
                                  : Icons.person,
                          size: 16,
                          color: TColors.darkerGrey,
                        ),
                        const SizedBox(width: TSizes.xs),
                        Text(
                          '$age years',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      'Daily Medication: $dailyMedicationUsage times',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: TColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateAge(String dateOfBirth) {
    try {
      // Print the date string for debugging
      print('Date of birth string: $dateOfBirth');

      // Try to parse the date
      DateTime dob;

      // Check if the date is in a different format
      if (dateOfBirth.contains('/')) {
        // Handle MM/DD/YYYY format
        final parts = dateOfBirth.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          dob = DateTime(year, month, day);
        } else {
          throw FormatException('Invalid date format');
        }
      } else if (dateOfBirth.contains('-')) {
        // Handle YYYY-MM-DD format
        dob = DateTime.parse(dateOfBirth);
      } else {
        // Try to parse as is
        dob = DateTime.parse(dateOfBirth);
      }

      final today = DateTime.now();
      int age = today.year - dob.year;
      final monthDiff = today.month - dob.month;

      if (monthDiff < 0 || (monthDiff == 0 && today.day < dob.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      print('Error calculating age: $e');
      return 'Unknown';
    }
  }
}
