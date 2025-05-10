import 'package:asthma_app/features/asthma/screens/admin_page/admin_healthcare_page.dart';
import 'package:asthma_app/features/asthma/screens/admin_page/admin_navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_count_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';

class HealthcareCountCard extends StatelessWidget {
  const HealthcareCountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HealthcareCountController());
    final navController = Get.find<AdminNavigationController>();
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        navController.selectedIndex.value = 1; // Healthcare tab index
      },
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: darkMode ? TColors.dark : Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    color: TColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: TColors.warning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(
                  'Pending Approvals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  if (controller.isLoading.value) {
                    return const TShimmerEffect(width: 80, height: 30);
                  }
                  return Text(
                    '${controller.unapprovedCount.value}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: TColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                  );
                }),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Text(
                    'Healthcare Waiting for Approval',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TColors.textsecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
