import 'package:asthma_app/features/personalization/screens/dependent/manage_dependent_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/data/repositories/dependent/dependent_repository.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asthma_app/utils/logger.dart';

class DependentController extends GetxController {
  static DependentController get instance => Get.find();

  final dependentRepository = Get.put(DependentRepository());
  final profileLoading = false.obs;
  final imageUploading = false.obs;
  final dependents = <DependentModel>[].obs;

  // Form controllers
  final name = TextEditingController();
  final gender = TextEditingController();
  final dateOfBirth = TextEditingController();
  final relation = TextEditingController();
  final dailyMedicationUsage = TextEditingController();
  final selectedGender = ''.obs;
  final selectedRelation = ''.obs;
  final selectedDailyMedicationUsage = '0'.obs;
  final selectedDob = Rxn<DateTime>();
  final profileImage = Rxn<XFile>();
  GlobalKey<FormState> dependentFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserDependents();
  }

  @override
  void onClose() {
    name.dispose();
    gender.dispose();
    dateOfBirth.dispose();
    relation.dispose();
    dailyMedicationUsage.dispose();
    super.onClose();
  }

  /// Fetch all dependents for the current user
  Future<void> fetchUserDependents() async {
    try {
      profileLoading.value = true;
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDependents =
            await dependentRepository.fetchUserDependents(userId);
        dependents.value = userDependents;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Add new dependent
  Future<void> addDependent() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Adding dependent...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!dependentFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw 'User not found';

      // Create new dependent
      final newDependent = DependentModel(
        id: FirebaseFirestore.instance.collection('Dependents').doc().id,
        userId: userId,
        name: name.text.trim(),
        gender: selectedGender.value,
        dateOfBirth: dateOfBirth.text.trim(),
        profilePicture: '',
        relation: selectedRelation.value,
        dailyMedicationUsage: selectedDailyMedicationUsage.value,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      // Save to Firestore
      await dependentRepository.saveDependentRecord(newDependent);

      // Update UI
      dependents.add(newDependent);

      // Clear form
      clearForm();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Success', message: 'Dependent added successfully');

      // Redirect to Manage Dependent Screen
      Get.off(() => const ManageDependentScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update dependent
  Future<void> updateDependent(DependentModel dependent) async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Updating dependent...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Save to Firestore
      await dependentRepository.updateDependentRecord(dependent);

      // Update UI
      final index = dependents.indexWhere((d) => d.id == dependent.id);
      if (index != -1) {
        dependents[index] = dependent;
      }

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Success', message: 'Dependent updated successfully');

      // Redirect to Manage Dependent Screen
      Get.off(() => const ManageDependentScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLogger.error('Failed to update dependent', e);
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Delete dependent
  Future<void> deleteDependent(String dependentId) async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Deleting dependent...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Delete from Firestore
      await dependentRepository.removeDependentRecord(dependentId);

      // Update UI
      dependents.removeWhere((d) => d.id == dependentId);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Success', message: 'Dependent deleted successfully');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Clear form
  void clearForm() {
    name.clear();
    gender.clear();
    dateOfBirth.clear();
    relation.clear();
    dailyMedicationUsage.clear();
    selectedGender.value = '';
    selectedRelation.value = '';
    selectedDailyMedicationUsage.value = '0';
    selectedDob.value = null;
    profileImage.value = null;
  }

  /// Upload Profile Image
  Future<String> uploadDependentImage(String dependentId, XFile image) async {
    try {
      imageUploading.value = true;
      // Upload Image
      final imageUrl = await dependentRepository.uploadImage(
          'Dependents/Images/Profile/$dependentId/', image);

      // Update Dependent Image Record
      final dependent = dependents.firstWhere((d) => d.id == dependentId);
      final updatedDependent = DependentModel(
        id: dependent.id,
        userId: dependent.userId,
        name: dependent.name,
        gender: dependent.gender,
        dateOfBirth: dependent.dateOfBirth,
        profilePicture: imageUrl,
        relation: dependent.relation,
        dailyMedicationUsage: dependent.dailyMedicationUsage,
        createdAt: dependent.createdAt,
        updatedAt: Timestamp.now(),
      );

      // Update in Firestore
      await dependentRepository.updateDependentRecord(updatedDependent);

      // Update local data
      final index = dependents.indexWhere((d) => d.id == dependentId);
      if (index != -1) {
        dependents[index] = updatedDependent;
      }

      TLoaders.successSnackBar(
          title: 'Success', message: 'Profile image has been updated!');

      return imageUrl;
    } catch (e) {
      TLogger.error('Failed to upload dependent image', e);
      TLoaders.errorSnackBar(
          title: 'Oh Snap!', message: 'Something went wrong: $e');
      return '';
    } finally {
      imageUploading.value = false;
    }
  }

  /// Pick image
  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        profileImage.value = image;
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Oh Snap!',
          message: 'Something went wrong while picking image');
    }
  }
}
