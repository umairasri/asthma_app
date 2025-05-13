import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/text_strings.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:get/get.dart';

class CurrentSelectionCard extends StatelessWidget {
  final VoidCallback onTap;
  final PatientController userController;
  final SelectedDependentController selectedDependentController;

  const CurrentSelectionCard({
    super.key,
    required this.onTap,
    required this.userController,
    required this.selectedDependentController,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = selectedDependentController.selectionType.value == 'user';
    final name = isUser
        ? userController.user.value.username
        : selectedDependentController.selectedDependent.value?.name ??
            'Unknown';
    final gender = isUser
        ? userController.user.value.gender
        : selectedDependentController.selectedDependent.value?.gender ?? '';
    final age = isUser
        ? _calculateAge(userController.user.value.dateOfBirth)
        : _calculateAge(
            selectedDependentController.selectedDependent.value?.dateOfBirth ??
                '');
    final medicationFrequency = isUser
        ? userController.user.value.evohaler
        : selectedDependentController.selectedDependent.value?.evohaler ?? '0';
    final profilePicture = isUser
        ? (userController.user.value.profilePicture.isNotEmpty
            ? userController.user.value.profilePicture
            : TImages.user)
        : (selectedDependentController
                    .selectedDependent.value?.profilePicture?.isNotEmpty ??
                false
            ? selectedDependentController
                .selectedDependent.value!.profilePicture!
            : TImages.user);

    return Card(
      elevation: 2,
      shadowColor: TColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        side: BorderSide(
          color: TColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TColors.primary.withOpacity(0.05),
                TColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image with border
              Padding(
                padding: const EdgeInsets.only(top: TSizes.lg),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TColors.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: TCircularImage(
                    image: profilePicture,
                    width: 65,
                    height: 65,
                    padding: 0,
                    isNetworkImage: profilePicture != TImages.user,
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: TColors.dark,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusMd),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.sm,
                            vertical: TSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                gender.toLowerCase() == 'male'
                                    ? Icons.male
                                    : gender.toLowerCase() == 'female'
                                        ? Icons.female
                                        : Icons.person,
                                size: 16,
                                color: TColors.primary,
                              ),
                              const SizedBox(width: TSizes.xs),
                              Text(
                                '$age years',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: TColors.dark,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.sm,
                        vertical: TSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 16,
                            color: TColors.primary,
                          ),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            'Medication: $medicationFrequency',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: TColors.dark,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
