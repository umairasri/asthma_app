import 'package:asthma_app/features/asthma/screens/admin_page/admin_healthcare_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:asthma_app/features/asthma/screens/admin_page/admin_home_page.dart';
import 'package:asthma_app/features/personalization/screens/settings/settings.dart';

class AdminNavigationMenu extends StatelessWidget {
  const AdminNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminNavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      extendBody: true, // Let the nav bar float with transparency
      bottomNavigationBar: Obx(
        () => Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkMode ? TColors.dark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: NavigationBar(
              height: 70,
              elevation: 0,
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) =>
                  controller.selectedIndex.value = index,
              backgroundColor: Colors.transparent,
              indicatorColor: darkMode
                  ? Colors.white.withOpacity(0.05)
                  : TColors.primary.withOpacity(0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Iconsax.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Iconsax.health),
                  label: 'Healthcare',
                ),
                NavigationDestination(
                  icon: Icon(Iconsax.setting_2),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class AdminNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  // Placeholder screens - you'll need to create these admin-specific screens
  final screens = [
    const AdminHomePage(), // Dashboard
    const AdminHealthcarePage(), // Healthcare Management
    const SettingScreen(), // Settings
  ];
}

// Placeholder screens - Create these in separate files later
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Users Management'));
  }
}

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Analytics'));
  }
}
