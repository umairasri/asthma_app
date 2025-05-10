import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';

class SelectDependentDialog extends StatelessWidget {
  final PatientController userController;
  final DependentController dependentController;
  final SelectedDependentController selectedDependentController;
  final Function(dynamic)? onParticipantSelected;

  const SelectDependentDialog({
    super.key,
    required this.userController,
    required this.dependentController,
    required this.selectedDependentController,
    this.onParticipantSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final user = userController.user.value;
    final dependents = dependentController.dependents;

    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Participant',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    selectedDependentController.selectedDependent.value = null;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Patient Card
            if (user != null)
              _buildSelectionCard(
                context,
                isSelected:
                    selectedDependentController.selectionType.value == 'user',
                isPatient: true,
                onTap: () {
                  selectedDependentController.selectUser();
                  onParticipantSelected?.call(user);
                  Navigator.pop(context);
                },
                image: user.profilePicture.isNotEmpty
                    ? user.profilePicture
                    : TImages.user,
                name: user.username,
                gender: user.gender,
                age: _calculateAge(user.dateOfBirth),
                relation: 'Main Account',
              ),

            // Dependents List
            if (dependents.isNotEmpty) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Dependents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ...dependents.map((dependent) => _buildSelectionCard(
                    context,
                    isSelected:
                        selectedDependentController.selectionType.value ==
                                'dependent' &&
                            selectedDependentController
                                    .selectedDependent.value?.id ==
                                dependent.id,
                    isPatient: false,
                    onTap: () {
                      selectedDependentController.selectDependent(dependent);
                      onParticipantSelected?.call(dependent);
                      Navigator.pop(context);
                    },
                    image: dependent.profilePicture.isNotEmpty
                        ? dependent.profilePicture
                        : TImages.user,
                    name: dependent.name,
                    gender: dependent.gender,
                    age: _calculateAge(dependent.dateOfBirth),
                    relation: dependent.relation,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required bool isSelected,
    required bool isPatient,
    required VoidCallback onTap,
    required String image,
    required String name,
    required String gender,
    required String age,
    required String relation,
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
                          '$age years old',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      isPatient ? 'Main Account' : relation,
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
      DateTime dob;
      if (dateOfBirth.contains('/')) {
        final parts = dateOfBirth.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          dob = DateTime(year, month, day);
        } else {
          throw FormatException('Invalid date format');
        }
      } else {
        dob = DateTime.parse(dateOfBirth);
      }

      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return 'Unknown';
    }
  }
}
