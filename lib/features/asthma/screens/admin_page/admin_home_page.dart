import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/common/widgets/user_statistics_chart.dart';
import 'package:asthma_app/features/personalization/widgets/healthcare_count_card.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/personalization/controllers/admin_controller.dart';
import 'package:asthma_app/common/widgets/logout_confirmation_dialog.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_count_controller.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.instance;
    // Initialize and refresh healthcare count controller
    final healthcareCountController = Get.put(HealthcareCountController());

    // Refresh both admin and healthcare data
    controller.refreshAdminData();
    healthcareCountController.fetchCounts();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            TPrimaryHeaderContainer(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: TSizes.spaceBtwItems * 2),
                    ListTile(
                      leading: Obx(() {
                        final networkImage =
                            controller.admin.value.profilePicture;
                        final image = networkImage.isNotEmpty
                            ? networkImage
                            : TImages.admin;
                        return controller.imageUploading.value
                            ? const TShimmerEffect(
                                width: 50, height: 50, radius: 50)
                            : TCircularImage(
                                image: image,
                                width: 50,
                                height: 50,
                                padding: 0,
                                isNetworkImage: networkImage.isNotEmpty,
                              );
                      }),
                      title: Obx(() {
                        if (controller.profileLoading.value) {
                          return const TShimmerEffect(width: 80, height: 15);
                        } else {
                          return Text(
                            '${controller.admin.value.firstName} ${controller.admin.value.lastName}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(color: TColors.white),
                          );
                        }
                      }),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),

            /// Body
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Column(
                children: [
                  HealthcareCountCard(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // User Statistics Chart
                  Obx(() => healthcareCountController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : UserStatisticsChart(
                          healthcareUsers:
                              healthcareCountController.approvedCount.value,
                          patientUsers:
                              healthcareCountController.patientCount.value,
                          healthcareGrowth:
                              healthcareCountController.getHealthcareGrowth(),
                          patientGrowth:
                              healthcareCountController.getPatientGrowth(),
                          timePeriod: 'This Month',
                        )),

                  const SizedBox(height: 100),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
