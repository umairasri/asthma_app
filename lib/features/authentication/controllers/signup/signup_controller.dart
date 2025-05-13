import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/data/repositories/patient/patient_repository.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';
import 'package:asthma_app/features/authentication/screens/signup/verify_email.dart';
import 'package:asthma_app/features/personalization/models/patient_model.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/formatters/formatter.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs; // Observable for hiding/showing password
  final privacyPolicy = true.obs; // Observable for privacy policy acceptance
  final email = TextEditingController(); // Controller for email input
  final firstName = TextEditingController(); // Controller for first name input
  final lastName = TextEditingController(); // Controller for last name input
  final username = TextEditingController(); // Controller for username input
  final password = TextEditingController(); // Controller for password input
  final phoneNumber =
      TextEditingController(); // Controller for phoneNumber input
  GlobalKey<FormState> signupFormKey =
      GlobalKey<FormState>(); // Form key for form validation

  /// -- SIGNUP
  void signup() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        // Remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!signupFormKey.currentState!.validate()) {
        // Remove Loader
        TFullScreenLoader.stopLoading();
        return;
      }

      // Privacy Policy Check
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message:
              'In order to create account, you must have to read and accept the Privacy Policy & Terms of Use.',
        );
        // Remove Loader
        TFullScreenLoader.stopLoading();

        return;
      }

      // Register user in the Firebase Authentication
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
              email.text.trim(), password.text.trim());

      // Create User record
      final user = UserModel(
        userId: userCredential.user!.uid,
        email: email.text.trim(),
        role: UserRole.patient,
      );

      final userRepository = Get.put(UserRepository());
      await userRepository.createUser(user);

      // Create Patient record
      final newPatient = PatientModel(
        id: userCredential.user!.uid,
        userId: userCredential.user!.uid,
        username: username.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
        gender: '', // Empty string for gender
        dateOfBirth: '', // Empty string for date of birth
        evohaler: '', // Empty string for medication frequency
      );

      final patientRepository = Get.put(PatientRepository());
      await patientRepository.saveUserRecord(newPatient);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your account has been created! Verify email to continue.');

      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(
            email: email.text.trim(),
          ));
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some Generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
