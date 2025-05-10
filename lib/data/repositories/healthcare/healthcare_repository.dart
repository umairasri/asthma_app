import 'dart:io';

import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/utils/exceptions/firebase_exceptions.dart';
import 'package:asthma_app/utils/exceptions/format_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Repository class for healthcare-related operations.
class HealthcareRepository extends GetxController {
  static HealthcareRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save healthcare data to Firestore.
  Future<void> saveHealthcareRecord(HealthcareModel healthcare) async {
    try {
      // Check if user has healthcare role
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(healthcare.id)
          .get();

      if (!userDoc.exists || userDoc.data()?['Role'] != 'healthcare') {
        throw 'User is not a healthcare provider';
      }

      await _db
          .collection("Healthcare")
          .doc(healthcare.id)
          .set(healthcare.toJson());
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

  /// Function to fetch healthcare details based on user ID.
  Future<HealthcareModel> fetchHealthcareDetails() async {
    try {
      final currentUser = AuthenticationRepository.instance.authUser;
      if (currentUser == null) throw 'No authenticated user found';

      // Check if user is a patient or admin
      final patientDoc = await FirebaseFirestore.instance
          .collection('Patients')
          .doc(currentUser.uid)
          .get();
      final adminDoc = await FirebaseFirestore.instance
          .collection('Admins')
          .doc(currentUser.uid)
          .get();

      if (patientDoc.exists || adminDoc.exists) {
        throw 'User is a patient or admin';
      }

      // Check if user has healthcare role
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data()?['Role'] != 'healthcare') {
        throw 'User is not a healthcare provider';
      }

      final documentSnapshot =
          await _db.collection("Healthcare").doc(currentUser.uid).get();
      if (documentSnapshot.exists) {
        return HealthcareModel.fromSnapshot(documentSnapshot);
      } else {
        return HealthcareModel.empty();
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

  /// Function to update healthcare data in Firestore.
  Future<void> updateHealthcareDetails(
      HealthcareModel updatedHealthcare) async {
    try {
      await _db
          .collection("Healthcare")
          .doc(updatedHealthcare.id)
          .update(updatedHealthcare.toJson());
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

  /// Update any field in specify Healthcare Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Healthcare")
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

  /// Function to remove healthcare data from Firestore
  Future<void> removeHealthcareRecord(String userId) async {
    try {
      await _db.collection("Healthcare").doc(userId).delete();
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

  /// Get all healthcare providers
  Future<List<HealthcareModel>> getAllHealthcareProviders() async {
    try {
      final querySnapshot = await _db.collection("Healthcare").get();

      return querySnapshot.docs
          .map((doc) => HealthcareModel.fromSnapshot(doc))
          .toList();
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

  /// Get all pending healthcare providers
  Future<List<HealthcareModel>> getPendingHealthcareProviders() async {
    try {
      final querySnapshot = await _db
          .collection("Healthcare")
          .where("IsApproved", isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => HealthcareModel.fromSnapshot(doc))
          .toList();
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

  /// Approve healthcare provider
  Future<void> approveHealthcareProvider(String healthcareId) async {
    try {
      await _db
          .collection("Healthcare")
          .doc(healthcareId)
          .update({"IsApproved": true});
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

  /// Reject healthcare provider
  Future<void> rejectHealthcareProvider(String healthcareId) async {
    try {
      await _db
          .collection("Healthcare")
          .doc(healthcareId)
          .update({"IsApproved": false});
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
