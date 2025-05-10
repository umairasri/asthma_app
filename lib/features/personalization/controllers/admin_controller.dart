import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:asthma_app/data/repositories/admin/admin_repository.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';
import 'package:asthma_app/features/personalization/models/admin_model.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';

class AdminController extends GetxController {
  static AdminController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<AdminModel> admin = AdminModel.empty().obs;
  final _hasInitialized = false.obs;

  final hidePassword = true.obs;
  final imageUploading = false.obs;
  final adminRepository = Get.put(AdminRepository());
  final userRepository = Get.put(UserRepository());

  // Form Keys
  final updateAdminNameFormKey = GlobalKey<FormState>();

  // Text Controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAdminRecord();
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    super.onClose();
  }

  /// Fetch admin record
  Future<void> fetchAdminRecord() async {
    try {
      profileLoading.value = true;
      final adminData = await adminRepository.fetchAdminDetails();
      if (adminData.id.isNotEmpty) {
        admin.value = adminData;
      } else {
        // If no admin data found, check if user is an admin
        final user = AuthenticationRepository.instance.authUser;
        if (user != null) {
          // Check if user has admin role
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();

          if (userDoc.exists && userDoc.data()?['Role'] == 'admin') {
            // Create User record
            final userModel = UserModel(
              userId: user.uid,
              email: user.email ?? '',
              role: UserRole.admin,
            );
            await userRepository.createUser(userModel);

            // Create Admin record
            final adminData = AdminModel(
              id: user.uid,
              userId: user.uid,
              firstName: '',
              lastName: '',
              profilePicture: '',
            );
            await adminRepository.saveAdminRecord(adminData);
            admin.value = adminData;
          }
        }
      }
    } catch (e) {
      admin.value = AdminModel.empty();
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to fetch admin data');
    } finally {
      profileLoading.value = false;
    }
  }

  /// Refresh admin data
  Future<void> refreshAdminData() async {
    await fetchAdminRecord();
  }

  /// Save admin Record
  Future<void> saveAdminRecord(UserCredential? userCredentials) async {
    try {
      // First Update Rx Admin and then check if admin data is already stored. If not store new data
      await fetchAdminRecord();

      // If no record already stored
      if (admin.value.id.isEmpty) {
        if (userCredentials != null) {
          // Check if user has admin role
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userCredentials.user!.uid)
              .get();

          if (userDoc.exists && userDoc.data()?['Role'] == 'admin') {
            // Create User record
            final userModel = UserModel(
              userId: userCredentials.user!.uid,
              email: userCredentials.user!.email ?? '',
              role: UserRole.admin,
            );
            await userRepository.createUser(userModel);

            // Create admin record
            final adminData = AdminModel(
              id: userCredentials.user!.uid,
              userId: userCredentials.user!.uid,
              firstName: '',
              lastName: '',
              profilePicture: '',
            );

            // Save your data
            await adminRepository.saveAdminRecord(adminData);
          }
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(
          title: 'Data not saved',
          message:
              'Something went wrong while saving your information. You can re-save your data in your Profile.');
    }
  }

  /// Update admin profile
  Future<void> updateAdminProfile(AdminModel updatedAdmin) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Updating your profile...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update admin record
      await adminRepository.updateAdminDetails(updatedAdmin);

      // Update local admin data
      admin.value = updatedAdmin;

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Your profile has been updated!');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Upload Profile Image
  uploadAdminProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        imageUploading.value = true;
        // Upload Image
        final imageUrl =
            await adminRepository.uploadImage('Admin/Images/Profile/', image);

        // Update Admin Image Record
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await adminRepository.updateSingleField(json);

        // Update local admin data
        admin.value.profilePicture = imageUrl;
        admin.refresh();

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

  /// Create a new admin account
  Future<void> createAdminAccount(
      String email, String password, String firstName, String lastName) async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Creating admin account...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Create admin account
      await adminRepository.createAdminAccount(
          email, password, firstName, lastName);

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Admin account has been created!');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Update Admin Name
  Future<void> updateAdminName() async {
    try {
      if (!updateAdminNameFormKey.currentState!.validate()) return;

      TFullScreenLoader.openLoadingDialog(
          'Updating name...', TImages.docerAnimation);

      // Check Internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Create new admin record with updated name
      final updatedAdmin = AdminModel(
        id: admin.value.id,
        userId: admin.value.userId,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        profilePicture: admin.value.profilePicture,
      );
      await updateAdminProfile(updatedAdmin);

      TFullScreenLoader.stopLoading();

      TLoaders.successSnackBar(
          title: 'Success', message: 'Your name has been updated!');

      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
