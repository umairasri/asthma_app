import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/common/widgets/logout_confirmation_dialog.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_navigation_menu.dart';
import 'package:asthma_app/features/asthma/widgets/healthcare_statistics.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/features/personalization/controllers/user_controller.dart';

class HealthcareHomePage extends StatelessWidget {
  const HealthcareHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HealthcareController.instance;
    final userController = UserController.instance;

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
                            controller.healthcare.value.profilePicture;
                        final image = networkImage.isNotEmpty
                            ? networkImage
                            : TImages.facility;
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
                            controller.healthcare.value.facilityName,
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

            /// Statistics
            const HealthcareStatistics(),
          ],
        ),
      ),
    );
  }
}
