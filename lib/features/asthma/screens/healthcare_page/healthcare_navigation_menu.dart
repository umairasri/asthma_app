import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_event_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_home_page.dart';
import 'package:asthma_app/features/personalization/screens/settings/settings.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';

class HealthcareNavigationMenu extends StatelessWidget {
  const HealthcareNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the HealthcareController
    Get.put(HealthcareController());

    final controller = Get.put(HealthcareNavigationController());
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
                  controller.navigateToPage(index),
              backgroundColor: Colors.transparent,
              indicatorColor: darkMode
                  ? Colors.white.withOpacity(0.05)
                  : TColors.primary.withOpacity(0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
                NavigationDestination(
                    icon: Icon(Iconsax.clipboard_tick), label: 'Events'),
                NavigationDestination(
                    icon: Icon(Iconsax.chart_square), label: 'Analytics'),
                NavigationDestination(
                    icon: Icon(Iconsax.user), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class HealthcareNavigationController extends GetxController {
  static HealthcareNavigationController get instance => Get.find();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HealthcareHomePage(),
    const HealthcareEventPage(),
    const PlaceholderScreen(title: 'Analytics'),
    const SettingScreen()
  ];

  // Method to navigate to a specific page
  void navigateToPage(int index) {
    selectedIndex.value = index;
    if (Get.currentRoute != '/HealthcareNavigationMenu') {
      Get.off(
        () => const HealthcareNavigationMenu(),
        transition: Transition.noTransition,
      );
    }
  }
}

// Placeholder screen for tabs that haven't been implemented yet
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is coming soon',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
