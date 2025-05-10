import 'package:asthma_app/data/repositories/patient/patient_repository.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/screens/profile/profile.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Controller to manage gender update
class UpdateGenderController extends GetxController {
  static UpdateGenderController get instance => Get.find();

  final userController = PatientController.instance;
  final userRepository = Get.put(PatientRepository());
  GlobalKey<FormState> genderFormKey = GlobalKey<FormState>();
  RxString selectedGender = ''.obs;

  /// Init with existing gender (if available)
  @override
  void onInit() {
    initializedGender();
    super.onInit();
  }

  void initializedGender() {
    selectedGender.value = userController.user.value.gender;
  }

  Future<void> updateGender() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Updating your gender...', TImages.docerAnimation);

      // Check Internet Connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!genderFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Prepare update data
      Map<String, dynamic> genderData = {
        'Gender': selectedGender.value,
      };
      await userRepository.updateSingleField(genderData);

      // Update local user model
      userController.user.value.gender = selectedGender.value;
      await userController.fetchUserRecord();

      // Stop Loader
      TFullScreenLoader.stopLoading();

      // Show Success
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your gender has been updated.',
      );

      // Navigate back to profile
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
