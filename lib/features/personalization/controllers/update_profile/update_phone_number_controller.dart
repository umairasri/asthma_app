import 'package:asthma_app/data/repositories/patient/patient_repository.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/screens/profile/profile.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Controller to manage user-related functionality
class UpdatePhoneNumberController extends GetxController {
  static UpdatePhoneNumberController get instance => Get.find();

  final phoneNumber = TextEditingController();
  final userController = PatientController.instance;
  final userRepository = Get.put(PatientRepository());
  GlobalKey<FormState> updatePhoneNumberFormKey = GlobalKey<FormState>();

  /// init user data when Home Screen appears
  @override
  void onInit() {
    initializedNames();
    super.onInit();
  }

  /// Fetch user record
  Future<void> initializedNames() async {
    phoneNumber.text = userController.user.value.phoneNumber;
  }

  Future<void> updatePhoneNumber() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'We are updating your information...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!updatePhoneNumberFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update user's first & last name in Firebase Firestore
      Map<String, dynamic> number = {
        'PhoneNumber': phoneNumber.text.trim(),
      };
      await userRepository.updateSingleField(number);

      // Update the Rx User value
      userController.user.value.phoneNumber = phoneNumber.text.trim();

      await userController.fetchUserRecord();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your Phone Number has been updated.');

      // Move to previous screen.
      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
