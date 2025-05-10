import 'dart:io';

import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/personalization/models/admin_model.dart';
import 'package:asthma_app/utils/exceptions/firebase_exceptions.dart';
import 'package:asthma_app/utils/exceptions/format_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';

/// Repository class for admin-related operations.
class AdminRepository extends GetxController {
  static AdminRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserRepository _userRepository = Get.put(UserRepository());

  /// Function to save admin data to Firestore.
  Future<void> saveAdminRecord(AdminModel admin) async {
    try {
      await _db.collection("Admins").doc(admin.id).set(admin.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to fetch admin details based on user ID.
  Future<AdminModel> fetchAdminDetails() async {
    try {
      final documentSnapshot = await _db
          .collection("Admins")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return AdminModel.fromSnapshot(documentSnapshot);
      } else {
        return AdminModel.empty();
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to update admin data in Firestore.
  Future<void> updateAdminDetails(AdminModel updatedAdmin) async {
    try {
      await _db
          .collection("Admins")
          .doc(updatedAdmin.id)
          .update(updatedAdmin.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update any field in specify Admins Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Admins")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Function to remove admin data from Firestore
  Future<void> removeAdminRecord(String userId) async {
    try {
      await _db.collection("Admins").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Upload any image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Create a new admin account
  Future<void> createAdminAccount(
      String email, String password, String firstName, String lastName) async {
    try {
      // Create the user in Firebase Authentication
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(email, password);

      // Create the User record
      final user = UserModel(
        userId: userCredential.user!.uid,
        email: email,
        role: UserRole.admin,
      );
      await _userRepository.createUser(user);

      // Create the admin record in Firestore
      final admin = AdminModel(
        id: userCredential.user!.uid,
        userId: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
      );

      await saveAdminRecord(admin);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TFormatException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Create default admin account
  Future<void> createDefaultAdminAccount() async {
    try {
      // Check if any admin exists in the collection
      final adminQuery = await _db.collection("Admins").limit(1).get();
      if (adminQuery.docs.isNotEmpty) {
        return; // Admin already exists
      }

      // Create the default admin in Firebase Authentication
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword("admin@asthma.com", "Admin@123");

      // Create the User record
      final user = UserModel(
        userId: userCredential.user!.uid,
        email: "admin@asthma.com",
        role: UserRole.admin,
      );
      await _userRepository.createUser(user);

      // Create the admin record in Firestore
      final admin = AdminModel(
        id: userCredential.user!.uid,
        userId: userCredential.user!.uid,
        firstName: "Admin",
        lastName: "User",
      );

      await saveAdminRecord(admin);

      if (kDebugMode) {
        print('Default admin account created successfully');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(
            'Firebase error creating default admin: ${e.code} - ${e.message}');
      }
      // Don't throw the error, just log it
    } on FormatException catch (_) {
      if (kDebugMode) {
        print('Format error creating default admin');
      }
      // Don't throw the error, just log it
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(
            'Platform error creating default admin: ${e.code} - ${e.message}');
      }
      // Don't throw the error, just log it
    } catch (e) {
      if (kDebugMode) {
        print('Error creating default admin: $e');
      }
      // Don't throw the error, just log it
    }
  }
}
