import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/admin_controller.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/features/personalization/controllers/profile_type_controller.dart';
import 'package:asthma_app/features/personalization/controllers/user_controller.dart';
import 'package:asthma_app/common/widgets/list_tile/user_profile_tile.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change.gender.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_birth_of_date.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_name.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_phone_number.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_username.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_facility_name.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_facility_contact.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_facility_address.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_staff_name.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_staff_email.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_daily_medication.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/change_profile/change_admin_name.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final patientController = PatientController.instance;
    final adminController = Get.put(AdminController());
    final healthcareController = Get.put(HealthcareController());
    final profileTypeController = Get.put(ProfileTypeController());
    final userController = Get.put(UserController());

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        iconColor: TColors.dark,
      ),

      /// -- Body
      body: SingleChildScrollView(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Obx(() {
          // Determine which profile type to display
          switch (profileTypeController.profileType.value) {
            case ProfileType.admin:
              return _buildAdminProfile(
                  context, adminController, userController);
            case ProfileType.healthcare:
              return _buildHealthcareProfile(
                  context, healthcareController, userController);
            case ProfileType.user:
              return _buildUserProfile(
                  context, patientController, userController);
          }
        }),
      ),
    );
  }

  Widget _buildAdminProfile(BuildContext context, AdminController controller,
      UserController userEmailController) {
    return Column(
      children: [
        /// Profile Picture
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Obx(() {
                final networkImage = controller.admin.value.profilePicture;
                final image =
                    networkImage.isNotEmpty ? networkImage : TImages.admin;
                return controller.imageUploading.value
                    ? const TShimmerEffect(width: 80, height: 80, radius: 80)
                    : TCircularImage(
                        image: image,
                        width: 80,
                        height: 80,
                        padding: 0,
                        backgroundColor: TColors.accent,
                        isNetworkImage: networkImage.isNotEmpty,
                      );
              }),
              TextButton(
                onPressed: () => controller.uploadAdminProfilePicture(),
                child: const Text('Change Profile Picture'),
              ),
            ],
          ),
        ),

        /// Details
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        const TSectionHeading(
          title: 'Admin Information',
          showActionButton: false,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Obx(() {
          if (controller.profileLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              TProfileMenu(
                  title: 'Name',
                  value:
                      '${controller.admin.value.firstName} ${controller.admin.value.lastName}',
                  onPressed: () => Get.off(() => const ChangeAdminName())),
              const SizedBox(height: TSizes.iconXs),
              TProfileMenu(
                title: 'E-mail',
                value: userEmailController.getCurrentUserEmail() ?? '',
                onPressed: () {},
                hasIcon: false,
              ),
              const SizedBox(height: TSizes.iconXs),
            ],
          );
        }),

        // Delete Account button is disabled for admin
        const SizedBox(height: TSizes.spaceBtwItems),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        Center(
          child: TextButton(
            onPressed: null, // Disabled
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHealthcareProfile(BuildContext context,
      HealthcareController controller, UserController userEmailController) {
    return Column(
      children: [
        /// Profile Picture
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Obx(() {
                final networkImage = controller.healthcare.value.profilePicture;
                final image =
                    networkImage.isNotEmpty ? networkImage : TImages.facility;
                return controller.imageUploading.value
                    ? const TShimmerEffect(width: 80, height: 80, radius: 80)
                    : TCircularImage(
                        image: image,
                        width: 80,
                        height: 80,
                        padding: 0,
                        backgroundColor: TColors.accent,
                        isNetworkImage: networkImage.isNotEmpty,
                      );
              }),
              TextButton(
                onPressed: () => controller.uploadHealthcareProfilePicture(),
                child: const Text('Change Profile Picture'),
              ),
            ],
          ),
        ),

        /// Details
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        const TSectionHeading(
          title: 'Healthcare Facility Information',
          showActionButton: false,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        TProfileMenu(
          title: 'Facility Name',
          value: controller.healthcare.value.facilityName,
          onPressed: () => Get.off(() => const ChangeFacilityName()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Facility Email',
          value: userEmailController.getCurrentUserEmail() ?? '',
          onPressed: () {},
          hasIcon: false,
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Registration Number',
          value: controller.healthcare.value.licenseNumber,
          onPressed: () {},
          icon: Iconsax.copy,
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Facility Contact',
          value: '+6${controller.healthcare.value.facilityContactNumber}',
          onPressed: () => Get.off(() => const ChangeFacilityContact()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Address',
          value: controller.healthcare.value.facilityAddress,
          onPressed: () => Get.off(() => const ChangeFacilityAddress()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Staff Name',
          value: controller.healthcare.value.representativeName,
          onPressed: () => Get.off(() => const ChangeStaffName()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Staff Email',
          value: controller.healthcare.value.representativeEmail,
          onPressed: () => Get.off(() => const ChangeStaffEmail()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Registration Document',
          value: 'View Document',
          onPressed: () {
            if (controller.healthcare.value.registrationDocument.isNotEmpty) {
              // Open the document in a web view or download it
              Get.dialog(
                Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppBar(
                        title: Text('Registration Document'),
                      ),
                      Expanded(
                        child: Image.network(
                          controller.healthcare.value.registrationDocument,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: TSizes.iconXs),

        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),

        Center(
          child: TextButton(
            onPressed: () {
              // Show delete account confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                      'Are you sure you want to delete your healthcare account? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement healthcare account deletion
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, PatientController controller,
      UserController userEmailController) {
    return Column(
      children: [
        /// Profile Picture
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Obx(() {
                final networkImage = controller.user.value.profilePicture;
                final image =
                    networkImage.isNotEmpty ? networkImage : TImages.user;
                return controller.imageUploading.value
                    ? const TShimmerEffect(width: 80, height: 80, radius: 80)
                    : TCircularImage(
                        image: image,
                        width: 80,
                        height: 80,
                        padding: 0,
                        backgroundColor: TColors.accent,
                        isNetworkImage: networkImage.isNotEmpty,
                      );
              }),
              TextButton(
                onPressed: () => controller.uploadUserProfilePicture(),
                child: const Text('Change Profile Picture'),
              ),
            ],
          ),
        ),

        /// Details
        const SizedBox(height: TSizes.spaceBtwItems / 2),
        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),
        const TSectionHeading(
          title: 'Personal Information',
          showActionButton: false,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        TProfileMenu(
            title: 'Name',
            value: controller.user.value.fullName,
            onPressed: () => Get.off(() => const ChangeName())),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
            title: 'Username',
            value: controller.user.value.username,
            onPressed: () => Get.off(() => const ChangeUsername())),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'User ID',
          value: controller.user.value.id,
          icon: Iconsax.copy,
          onPressed: () {},
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'E-mail',
          value: userEmailController.getCurrentUserEmail() ?? '',
          onPressed: () {},
          hasIcon: false,
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Phone Number',
          value: '+6${controller.user.value.phoneNumber}',
          onPressed: () => Get.off(() => const ChangePhoneNumber()),
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Gender',
          value: controller.user.value.gender,
          onPressed: () => Get.off(() => const ChangeGender()),
          disabled: controller.user.value.gender.isNotEmpty,
        ),
        const SizedBox(height: TSizes.iconXs),

        TProfileMenu(
          title: 'Date of Birth',
          value: controller.user.value.dateOfBirth,
          onPressed: () => Get.off(() => const ChangeDateOfBirth()),
          disabled: controller.user.value.dateOfBirth.isNotEmpty,
        ),
        const SizedBox(height: TSizes.iconXs),
        TProfileMenu(
          title: 'Flixotide Evohaler',
          value: controller.user.value.evohaler,
          onPressed: () => Get.off(() => const ChangeDailyMedication()),
        ),
        const SizedBox(height: TSizes.iconXs),

        const Divider(),
        const SizedBox(height: TSizes.spaceBtwItems),

        Center(
          child: TextButton(
            onPressed: () => controller.deleteAccountWarningPopup(),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        )
      ],
    );
  }
}
