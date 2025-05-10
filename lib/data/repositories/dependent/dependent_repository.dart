import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DependentRepository extends GetxController {
  static DependentRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;

  /// Save dependent data to Firestore
  Future<void> saveDependentRecord(DependentModel dependent) async {
    try {
      await _db
          .collection('Dependents')
          .doc(dependent.id)
          .set(dependent.toJson());
    } catch (e) {
      throw 'Something went wrong while saving dependent data.';
    }
  }

  /// Fetch dependent details
  Future<DependentModel> fetchDependentDetails(String dependentId) async {
    try {
      final snapshot =
          await _db.collection('Dependents').doc(dependentId).get();
      if (snapshot.exists) {
        return DependentModel.fromJson(snapshot.data()!);
      } else {
        throw 'Dependent not found.';
      }
    } catch (e) {
      throw 'Something went wrong while fetching dependent data.';
    }
  }

  /// Fetch all dependents for a user
  Future<List<DependentModel>> fetchUserDependents(String userId) async {
    try {
      final snapshot = await _db
          .collection('Dependents')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => DependentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching dependents.';
    }
  }

  /// Update dependent data
  Future<void> updateDependentRecord(DependentModel dependent) async {
    try {
      await _db
          .collection('Dependents')
          .doc(dependent.id)
          .update(dependent.toJson());
    } catch (e) {
      throw 'Something went wrong while updating dependent data.';
    }
  }

  /// Delete dependent record
  Future<void> removeDependentRecord(String dependentId) async {
    try {
      await _db.collection('Dependents').doc(dependentId).delete();
    } catch (e) {
      throw 'Something went wrong while removing dependent data.';
    }
  }

  /// Upload Image
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = storage.ref().child(path).child(image.name);
      final uploadTask = await ref.putData(await image.readAsBytes());
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Something went wrong while uploading image.';
    }
  }
}
