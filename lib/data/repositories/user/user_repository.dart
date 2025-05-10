import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/exceptions/firebase_exceptions.dart';
import 'package:asthma_app/utils/exceptions/format_exceptions.dart';
import 'package:flutter/services.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new user with role
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.userId).set(user.toJson());
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

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _db.collection("Users").doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
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

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
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
