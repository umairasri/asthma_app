import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/asthma/screens/diary/widgets/select_dependent_popup.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';

class THomePageAppBar extends StatefulWidget {
  const THomePageAppBar({
    super.key,
  });

  @override
  State<THomePageAppBar> createState() => _THomePageAppBarState();
}

class _THomePageAppBarState extends State<THomePageAppBar> {
  late final PatientController userController;
  late final DependentController dependentController;
  late final SelectedDependentController selectedDependentController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    userController = Get.find<PatientController>();
    dependentController = Get.put(DependentController());
    selectedDependentController = Get.put(SelectedDependentController());

    _initializeData();
  }

  void _initializeData() {
    // Fetch user data
    userController.fetchUserRecord();
    // Listen for changes in user data
    ever(userController.user, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, refresh data
        _initializeData();
      }
    });
  }

  void _showSelectDependentPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectDependentPopup(
        dependentController: dependentController,
        selectedDependentController: selectedDependentController,
        userController: userController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TAppBar(
      title: Padding(
        padding: EdgeInsets.only(top: TSizes.sm),
        child: Row(
          children: [
            // Profile Image
            Obx(() {
              final networkImage =
                  selectedDependentController.getSelectionProfilePicture();
              final image =
                  networkImage.isNotEmpty ? networkImage : TImages.user;
              return userController.imageUploading.value
                  ? const TShimmerEffect(width: 40, height: 40, radius: 40)
                  : TCircularImage(
                      image: image,
                      width: 40,
                      height: 40,
                      padding: 0,
                      isNetworkImage: networkImage.isNotEmpty,
                    );
            }),
            const SizedBox(width: TSizes.iconXs),

            // User/Dependent Selection
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TTexts.homeAppbarTitle,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .apply(color: TColors.grey),
                  ),
                  Obx(() {
                    if (userController.profileLoading.value) {
                      return const TShimmerEffect(width: 80, height: 15);
                    } else {
                      final selectedName =
                          selectedDependentController.getSelectionName();
                      return Row(
                        children: [
                          Text(
                            selectedName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(color: TColors.white),
                          ),
                          // Only show selection button if there are dependents
                          if (dependentController.dependents.isNotEmpty) ...[
                            const SizedBox(width: TSizes.xs),
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: TColors.white),
                              onPressed: _showSelectDependentPopup,
                            ),
                          ],
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
