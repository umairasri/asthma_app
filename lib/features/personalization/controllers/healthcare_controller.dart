import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:asthma_app/data/repositories/healthcare/healthcare_repository.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:image_picker/image_picker.dart';

class HealthcareController extends GetxController {
  static HealthcareController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<HealthcareModel> healthcare = HealthcareModel.empty().obs;

  final hidePassword = true.obs;
  final imageUploading = false.obs;
  final healthcareRepository = Get.put(HealthcareRepository());
  final userRepository = Get.put(UserRepository());

  // Form Keys
  final updateFacilityNameFormKey = GlobalKey<FormState>();
  final updateFacilityContactFormKey = GlobalKey<FormState>();
  final updateFacilityAddressFormKey = GlobalKey<FormState>();
  final updateStaffNameFormKey = GlobalKey<FormState>();
  final updateStaffEmailFormKey = GlobalKey<FormState>();

  // Text Controllers
  final facilityName = TextEditingController();
  final facilityContact = TextEditingController();
  final facilityAddress = TextEditingController();
  final staffName = TextEditingController();
  final staffEmail = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchHealthcareRecord();
  }

  @override
  void onClose() {
    facilityName.dispose();
    facilityContact.dispose();
    facilityAddress.dispose();
    staffName.dispose();
    staffEmail.dispose();
    super.onClose();
  }

  /// Fetch healthcare record
  Future<void> fetchHealthcareRecord() async {
    try {
      profileLoading.value = true;
      final healthcareData =
          await healthcareRepository.fetchHealthcareDetails();
      this.healthcare(healthcareData);
    } catch (e) {
      healthcare(HealthcareModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save healthcare Record
  Future<void> saveHealthcareRecord(UserCredential? userCredentials) async {
    try {
      // First Update Rx Healthcare and then check if healthcare data is already stored. If not store new data
      await fetchHealthcareRecord();

      // If no record already stored
      if (healthcare.value.id.isEmpty) {
        if (userCredentials != null) {
          // Create User record
          final userModel = UserModel(
            userId: userCredentials.user!.uid,
            email: userCredentials.user!.email ?? '',
            role: UserRole.healthcare,
          );
          await userRepository.createUser(userModel);

          // Create healthcare record
          final healthcareData = HealthcareModel(
            id: userCredentials.user!.uid,
            userId: userCredentials.user!.uid,
            facilityName: '',
            licenseNumber: '',
            facilityContactNumber: '',
            facilityAddress: '',
            representativeName: '',
            representativeEmail: '',
            registrationDocument: '',
            profilePicture: '',
            isApproved: false,
          );

          // Save healthcare data
          await healthcareRepository.saveHealthcareRecord(healthcareData);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
          title: 'Data not saved',
          message:
              'Something went wrong while saving your information. You can re-save your data in your Profile.');
    }
  }

  /// Update healthcare profile
  Future<void> updateHealthcareProfile(
      HealthcareModel updatedHealthcare) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Updating your profile...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      await healthcareRepository.updateHealthcareDetails(updatedHealthcare);

      // Update local healthcare data
      healthcare(updatedHealthcare);

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Your profile has been updated!');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Upload Profile Image
  uploadHealthcareProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        imageUploading.value = true;
        // Upload Image
        final imageUrl = await healthcareRepository.uploadImage(
            'Healthcare/Images/Profile/', image);

        // Update Healthcare Image Record
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await healthcareRepository.updateSingleField(json);

        // Update local healthcare data
        healthcare.value.profilePicture = imageUrl;
        healthcare.refresh();

        TLoaders.successSnackBar(
            title: 'Congratulations',
            message: 'Your Profile Image has been updated!');
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Oh Snap!', message: 'Something went wrong: $e');
    } finally {
      imageUploading.value = false;
    }
  }

  /// Get all healthcare providers
  Future<List<HealthcareModel>> getAllHealthcareProviders() async {
    try {
      return await healthcareRepository.getAllHealthcareProviders();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Get all pending healthcare providers
  Future<List<HealthcareModel>> getPendingHealthcareProviders() async {
    try {
      return await healthcareRepository.getPendingHealthcareProviders();
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Approve healthcare provider
  Future<void> approveHealthcareProvider(String healthcareId) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Approving healthcare provider...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Approve healthcare provider
      await healthcareRepository.approveHealthcareProvider(healthcareId);

      await fetchHealthcareRecord();

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Healthcare provider has been approved!');

      Get.back(result: true);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Reject healthcare provider
  Future<void> rejectHealthcareProvider(String healthcareId) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Rejecting healthcare provider...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Reject healthcare provider
      await healthcareRepository.rejectHealthcareProvider(healthcareId);

      await fetchHealthcareRecord();

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Healthcare provider has been rejected!');

      Get.back(result: false);
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Facility Name
  Future<void> updateFacilityName() async {
    try {
      if (!updateFacilityNameFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating facility name...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      final updatedHealthcare = healthcare.value;
      updatedHealthcare.facilityName = facilityName.text.trim();
      await updateHealthcareProfile(updatedHealthcare);

      TFullScreenLoader.stopLoading();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Facility Contact
  Future<void> updateFacilityContact() async {
    try {
      if (!updateFacilityContactFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating contact number...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      final updatedHealthcare = healthcare.value;
      updatedHealthcare.facilityContactNumber = facilityContact.text.trim();
      await updateHealthcareProfile(updatedHealthcare);

      TFullScreenLoader.stopLoading();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Facility Address
  Future<void> updateFacilityAddress() async {
    try {
      if (!updateFacilityAddressFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating facility address...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      final updatedHealthcare = healthcare.value;
      updatedHealthcare.facilityAddress = facilityAddress.text.trim();
      await updateHealthcareProfile(updatedHealthcare);

      TFullScreenLoader.stopLoading();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Staff Name
  Future<void> updateStaffName() async {
    try {
      if (!updateStaffNameFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating staff name...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      final updatedHealthcare = healthcare.value;
      updatedHealthcare.representativeName = staffName.text.trim();
      await updateHealthcareProfile(updatedHealthcare);

      TFullScreenLoader.stopLoading();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Staff Email
  Future<void> updateStaffEmail() async {
    try {
      if (!updateStaffEmailFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating staff email...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update healthcare record
      final updatedHealthcare = healthcare.value;
      updatedHealthcare.representativeEmail = staffEmail.text.trim();
      await updateHealthcareProfile(updatedHealthcare);

      TFullScreenLoader.stopLoading();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
