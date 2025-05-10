import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/screens/dependent/add_dependent_screen.dart';
import 'package:asthma_app/features/personalization/screens/dependent/edit_dependent_screen.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

class ManageDependentScreen extends StatelessWidget {
  const ManageDependentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DependentController());

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Manage Dependents',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        iconColor: TColors.dark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Dependents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Expanded(
              child: Obx(
                () => controller.profileLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.dependents.isEmpty
                        ? const Center(
                            child: Text('No dependents added yet'),
                          )
                        : ListView.builder(
                            itemCount: controller.dependents.length,
                            itemBuilder: (context, index) {
                              final dependent = controller.dependents[index];
                              final age = _calculateAge(dependent.dateOfBirth);
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: dependent
                                            .profilePicture.isNotEmpty
                                        ? NetworkImage(dependent.profilePicture)
                                        : null,
                                    child: dependent.profilePicture.isEmpty
                                        ? const Icon(Iconsax.user)
                                        : null,
                                  ),
                                  title: Text(dependent.name),
                                  subtitle: Text(
                                      '${dependent.relation} - $age years old'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Iconsax.edit),
                                        onPressed: () => Get.off(() =>
                                            EditDependentScreen(
                                                dependent: dependent)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Iconsax.trash,
                                            color: TColors.error),
                                        onPressed: () =>
                                            _showDeleteConfirmationDialog(
                                                context, controller, dependent),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.off(() => const AddDependentScreen()),
        child: const Icon(Iconsax.add),
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

  void _showDeleteConfirmationDialog(
      BuildContext context, DependentController controller, dynamic dependent) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Dependent'),
        content: Text('Are you sure you want to delete ${dependent.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteDependent(dependent.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: TColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditDependentDialog(
      BuildContext context, DependentController controller, dynamic dependent) {
    // TODO: Implement edit dialog with form
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Dependent'),
        content: const Text('Edit functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
