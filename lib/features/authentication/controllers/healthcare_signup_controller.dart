import 'dart:io';
import 'package:asthma_app/features/authentication/screens/waiting_approval/waiting_approval_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/data/repositories/healthcare/healthcare_repository.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_home_page.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:image_picker/image_picker.dart';

class HealthcareSignupController extends GetxController {
  static HealthcareSignupController get instance => Get.find();

  final _auth = AuthenticationRepository.instance;
  late final HealthcareRepository _healthcareRepository;
  late final UserRepository _userRepository;

  // Form controllers
  final facilityNameController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final facilityEmailController = TextEditingController();
  final facilityContactNumberController = TextEditingController();
  final facilityAddressController = TextEditingController();
  final representativeNameController = TextEditingController();
  final representativeEmailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Password visibility
  final hidePassword = true.obs;

  // Variables
  final registrationDocumentName = ''.obs;
  final registrationDocumentError = ''.obs;
  final registrationDocument = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize the repositories
    _healthcareRepository = Get.put(HealthcareRepository());
    _userRepository = Get.put(UserRepository());
  }

  @override
  void onClose() {
    facilityNameController.dispose();
    licenseNumberController.dispose();
    facilityEmailController.dispose();
    facilityContactNumberController.dispose();
    facilityAddressController.dispose();
    representativeNameController.dispose();
    representativeEmailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    hidePassword.value = !hidePassword.value;
  }

  // Pick registration document
  Future<void> pickRegistrationDocument() async {
    try {
      final result = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (result != null) {
        final file = File(result.path);
        final extension = result.path.split('.').last.toLowerCase();

        if (extension == 'pdf' ||
            extension == 'jpg' ||
            extension == 'jpeg' ||
            extension == 'png') {
          registrationDocument.value = file;
          registrationDocumentName.value = result.name;
          registrationDocumentError.value = '';
        } else {
          registrationDocumentError.value = 'Please upload a PDF or image file';
        }
      }
    } catch (e) {
      registrationDocumentError.value = 'Error picking file: $e';
    }
  }

  // Register healthcare provider
  Future<void> registerHealthcareProvider() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information...', TImages.docerAnimation);

      // Check Internet Connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate form
      if (!formKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate registration document
      if (registrationDocument.value == null) {
        TFullScreenLoader.stopLoading();
        registrationDocumentError.value =
            'Please upload your registration document';
        return;
      }

      // Register user with email and password
      final userCredential = await _auth.registerWithEmailAndPassword(
          facilityEmailController.text.trim(), passwordController.text.trim());

      // Create User record
      final user = UserModel(
        userId: userCredential.user!.uid,
        email: facilityEmailController.text.trim(),
        role: UserRole.healthcare,
      );

      await _userRepository.createUser(user);

      // Upload registration document
      final documentUrl = await _healthcareRepository.uploadImage(
          'Healthcare/Documents/', XFile(registrationDocument.value!.path));

      // Create healthcare record
      final healthcare = HealthcareModel(
        id: userCredential.user!.uid,
        userId: userCredential.user!.uid,
        facilityName: facilityNameController.text.trim(),
        licenseNumber: licenseNumberController.text.trim(),
        facilityContactNumber: facilityContactNumberController.text.trim(),
        facilityAddress: facilityAddressController.text.trim(),
        representativeName: representativeNameController.text.trim(),
        representativeEmail: representativeEmailController.text.trim(),
        registrationDocument: documentUrl,
        isApproved: false,
      );

      // Save healthcare data
      await _healthcareRepository.saveHealthcareRecord(healthcare);

      // Stop loading
      TFullScreenLoader.stopLoading();

      // Show success message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message:
              'Your account has been created! Please wait for admin approval.');

      // Navigate to waiting approval screen
      Get.offAll(() => const WaitingApprovalScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
