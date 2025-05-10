import 'package:asthma_app/features/asthma/screens/analysis/analysis.dart';
import 'package:asthma_app/features/asthma/screens/event/event.dart';
import 'package:asthma_app/features/asthma/screens/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/features/asthma/screens/diary/diary.dart';
import 'package:asthma_app/features/personalization/screens/settings/settings.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
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
                NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
                NavigationDestination(
                    icon: Icon(Iconsax.clipboard_tick), label: 'Diary'),
                NavigationDestination(
                    icon: Icon(Iconsax.chart_square), label: 'Analytic'),
                NavigationDestination(
                    icon: Icon(Iconsax.calendar_tick), label: 'Event'),
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

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomePageScreen(),
    const DiaryScreen(),
    const AnalysisScreen(),
    const EventScreen(),
    const SettingScreen()
  ];
}
