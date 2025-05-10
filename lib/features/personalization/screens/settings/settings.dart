import 'package:asthma_app/common/widgets/logout_confirmation_dialog.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/asthma/screens/asthma_information_screen.dart';
import 'package:asthma_app/features/asthma/screens/event/events_history_screen.dart';
import 'package:asthma_app/features/notification/noti_service.dart';
import 'package:asthma_app/features/reminder/screens/reminder_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/common/widgets/list_tile/setting_menu_tile.dart';
import 'package:asthma_app/common/widgets/list_tile/user_profile_tile.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';
import 'package:asthma_app/features/personalization/screens/profile/profile.dart';
import 'package:asthma_app/features/personalization/screens/dependent/manage_dependent_screen.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:asthma_app/features/personalization/controllers/profile_type_controller.dart';
import 'package:asthma_app/features/personalization/controllers/admin_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';

import '../../../../utils/constants/sizes.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the profile type controller
    final profileTypeController = Get.put(ProfileTypeController());
    // Initialize and refresh admin controller
    final adminController = Get.put(AdminController());
    // Initialize the selected dependent controller
    final selectedDependentController = Get.put(SelectedDependentController());
    adminController.refreshAdminData();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: TColors.white),
                    ),
                  ),

                  /// User Profile Card
                  Obx(() => TProfileTile(
                        onPressed: () => Get.to(() => const ProfileScreen()),
                        profileType: profileTypeController.profileType.value,
                      )),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// -- Body
            Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Account Settings
                  TSectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),

                  // Profile menu item (shown for all user types)
                  TSettingsMenuTile(
                    icon: Iconsax.user_edit,
                    title: 'Profile',
                    subTitle: 'View and edit your personal details',
                    trailing: Icon(CupertinoIcons.right_chevron),
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),

                  // Conditional menu items based on user type
                  Obx(() {
                    // For healthcare providers and admins, only show profile and logout
                    if (profileTypeController.profileType.value ==
                            ProfileType.healthcare ||
                        profileTypeController.profileType.value ==
                            ProfileType.admin) {
                      return Column(
                        children: [
                          const SizedBox(height: TSizes.spaceBtwSections),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => LogoutConfirmationDialog.show(
                                context: context,
                                title: 'Logout',
                                content:
                                    'Are you sure you want to logout from your account?',
                              ),
                              child: const Text('Logout'),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                        ],
                      );
                    }

                    // For regular users, show all menu items
                    return Column(
                      children: [
                        TSettingsMenuTile(
                          icon: Iconsax.clipboard_tick,
                          title: 'Asthma Control Test',
                          subTitle: 'Evaluate current asthma condition',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () {},
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.clipboard_text,
                          title: 'Asthma Severity Level',
                          subTitle: 'Check asthma severity classification',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () {},
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.people,
                          title: 'Manage Dependent',
                          subTitle: 'Manage asthma for dependents',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () =>
                              Get.to(() => const ManageDependentScreen()),
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.warning_2,
                          title: 'Symptom Limit',
                          subTitle: 'Manage symptom limit warning',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () {
                            NotiService()
                                .showNotification(title: "Title", body: "Body");
                          },
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.notification,
                          title: 'Reminder',
                          subTitle: 'Set appointment and medication reminder',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () => Get.to(() => ReminderScreen()),
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.magic_star,
                          title: 'Event History',
                          subTitle: 'View your event history',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () => Get.to(() => EventsHistoryScreen()),
                        ),
                        TSettingsMenuTile(
                          icon: Iconsax.tag,
                          title: 'Asthma Information',
                          subTitle: 'View asthma information',
                          trailing: Icon(CupertinoIcons.right_chevron),
                          onTap: () => Get.to(() => AsthmaInformationScreen()),
                        ),

                        /// -- Logout Button
                        const SizedBox(height: TSizes.spaceBtwSections),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => LogoutConfirmationDialog.show(
                              context: context,
                              title: 'Logout',
                              content:
                                  'Are you sure you want to logout from your account?',
                            ),
                            child: const Text('Logout'),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                      ],
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
