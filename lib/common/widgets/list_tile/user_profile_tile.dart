import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/admin_controller.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/features/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';

enum ProfileType {
  user,
  admin,
  healthcare,
}

class TProfileTile extends StatelessWidget {
  const TProfileTile({
    super.key,
    required this.onPressed,
    this.profileType = ProfileType.user,
  });

  final VoidCallback onPressed;
  final ProfileType profileType;

  @override
  Widget build(BuildContext context) {
    switch (profileType) {
      case ProfileType.admin:
        return _buildAdminProfileTile(context);
      case ProfileType.healthcare:
        return _buildHealthcareProfileTile(context);
      case ProfileType.user:
        return _buildUserProfileTile(context);
    }
  }

  Widget _buildAdminProfileTile(BuildContext context) {
    final controller = AdminController.instance;
    final userController = UserController.instance;

    return ListTile(
      leading: Obx(() {
        final networkImage = controller.admin.value.profilePicture;
        final image = networkImage.isNotEmpty ? networkImage : TImages.admin;
        return controller.imageUploading.value
            ? const TShimmerEffect(width: 50, height: 50, radius: 50)
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
      subtitle: Obx(() => Text(
            userController.getCurrentUserEmail() ?? '',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: TColors.white),
          )),
      trailing: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Iconsax.edit,
          color: TColors.white,
        ),
      ),
    );
  }

  Widget _buildHealthcareProfileTile(BuildContext context) {
    final controller = HealthcareController.instance;
    final userController = UserController.instance;

    return ListTile(
      leading: Obx(() {
        final networkImage = controller.healthcare.value.profilePicture;
        final image = networkImage.isNotEmpty ? networkImage : TImages.facility;
        return controller.imageUploading.value
            ? const TShimmerEffect(width: 50, height: 50, radius: 50)
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
      subtitle: Obx(() => Text(
            userController.getCurrentUserEmail() ?? '',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: TColors.white),
          )),
      trailing: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Iconsax.edit,
          color: TColors.white,
        ),
      ),
    );
  }

  Widget _buildUserProfileTile(BuildContext context) {
    final controller = PatientController.instance;
    final userController = UserController.instance;

    return ListTile(
      leading: Obx(() {
        final networkImage = controller.user.value.profilePicture;
        final image = networkImage.isNotEmpty ? networkImage : TImages.user;
        return controller.imageUploading.value
            ? const TShimmerEffect(width: 50, height: 50, radius: 50)
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
            controller.user.value.fullName,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: TColors.white),
          );
        }
      }),
      subtitle: Obx(() => Text(
            userController.getCurrentUserEmail() ?? '',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: TColors.white),
          )),
      trailing: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Iconsax.edit,
          color: TColors.white,
        ),
      ),
    );
  }
}

// Keep the old TUserProfileTile for backward compatibility
class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TProfileTile(
      onPressed: onPressed,
      profileType: ProfileType.user,
    );
  }
}
