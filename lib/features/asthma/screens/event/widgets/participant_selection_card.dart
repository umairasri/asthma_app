import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:get/get.dart';

class ParticipantSelectionCard extends StatelessWidget {
  final VoidCallback onTap;
  final PatientController userController;
  final SelectedDependentController selectedDependentController;

  const ParticipantSelectionCard({
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
            'Select Participant';
    final gender = isUser
        ? userController.user.value.gender
        : selectedDependentController.selectedDependent.value?.gender ?? '';
    final age = isUser
        ? _calculateAge(userController.user.value.dateOfBirth)
        : _calculateAge(
            selectedDependentController.selectedDependent.value?.dateOfBirth ??
                '');
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
      elevation: 0,
      color: TColors.primary.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Row(
            children: [
              // Profile Image
              TCircularImage(
                image: profilePicture,
                width: 50,
                height: 50,
                isNetworkImage: profilePicture != TImages.user,
              ),
              const SizedBox(width: TSizes.spaceBtwItems),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      '${gender.isNotEmpty ? '$gender • ' : ''}$age years old',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                size: TSizes.iconSm,
                color: TColors.darkGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAge(String dateOfBirth) {
    if (dateOfBirth.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}
