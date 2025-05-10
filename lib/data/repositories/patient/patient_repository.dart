import 'dart:io';

import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/personalization/models/patient_model.dart';
import 'package:asthma_app/utils/exceptions/firebase_exceptions.dart';
import 'package:asthma_app/utils/exceptions/format_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Repository class for user-related operations.
class PatientRepository extends GetxController {
  static PatientRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data to Firestore.
  Future<void> saveUserRecord(PatientModel user) async {
    try {
      // Check if user has patient role
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.id)
          .get();

      if (!userDoc.exists || userDoc.data()?['Role'] != 'patient') {
        throw 'User is not a patient';
      }

      await _db.collection("Patients").doc(user.id).set(user.toJson());
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

  /// Function to fetch user details based on user ID.
  Future<PatientModel> fetchUserDetails() async {
    try {
      final currentUser = AuthenticationRepository.instance.authUser;
      if (currentUser == null) throw 'No authenticated user found';

      // Check if user is a healthcare provider or admin
      final healthcareDoc = await FirebaseFirestore.instance
          .collection('Healthcare')
          .doc(currentUser.uid)
          .get();
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(currentUser.uid)
          .get();

      if (healthcareDoc.exists || adminDoc.exists) {
        throw 'User is a healthcare provider or admin';
      }

      // Check if user has patient role
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['Role'] != 'patient') {
        throw 'User is not a patient';
      }

      final patientDoc = await FirebaseFirestore.instance
          .collection('Patients')
          .doc(currentUser.uid)
          .get();

      if (patientDoc.exists) {
        return PatientModel.fromSnapshot(patientDoc);
      } else {
        // Only create patient record if user has patient role
        final newUser = PatientModel(
          id: currentUser.uid,
          userId: currentUser.uid,
          firstName: '',
          lastName: '',
          username: '',
          profilePicture: '',
          phoneNumber: '',
          gender: '',
          dateOfBirth: '',
          dailyMedicationUsage: '',
        );

        await FirebaseFirestore.instance
            .collection('Patients')
            .doc(currentUser.uid)
            .set(newUser.toJson());

        return newUser;
      }
    } catch (e) {
      throw 'Failed to fetch user details: $e';
    }
  }

  /// Function to update user data in Firestore.
  Future<void> updateUserDetails(PatientModel updatedUser) async {
    try {
      await _db
          .collection("Patients")
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
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

  /// Update any field in specify Users Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Patients")
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

  /// Function to remove user data from Firestore
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Patients").doc(userId).delete();
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
}
