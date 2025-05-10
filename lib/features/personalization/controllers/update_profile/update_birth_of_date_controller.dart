import 'package:asthma_app/data/repositories/patient/patient_repository.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/screens/profile/profile.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpdateBirthOfDateController extends GetxController {
  static UpdateBirthOfDateController get instance => Get.find();

  final dateOfBirth = TextEditingController();
  final userController = PatientController.instance;
  final userRepository = Get.put(PatientRepository());
  GlobalKey<FormState> dobFormKey = GlobalKey<FormState>();

  /// Initialize with user's current birth date
  @override
  void onInit() {
    initializeDOB();
    super.onInit();
  }

  void initializeDOB() {
    dateOfBirth.text = userController.user.value.dateOfBirth;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      dateOfBirth.text = formatted;
    }
  }

  Future<void> updateDateOfBirth() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Updating your birth date...', TImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!dobFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> dobData = {
        'DateOfBirth': dateOfBirth.text.trim(),
      };
      await userRepository.updateSingleField(dobData);

      userController.user.value.dateOfBirth = dateOfBirth.text.trim();
      await userController.fetchUserRecord();

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Your date of birth has been updated.',
      );

      Get.off(() => const ProfileScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
