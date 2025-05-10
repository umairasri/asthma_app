import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/common/widgets/list_tile/user_profile_tile.dart';

class ProfileTypeController extends GetxController {
  static ProfileTypeController get instance => Get.find();

  final _auth = AuthenticationRepository.instance;
  final _db = FirebaseFirestore.instance;
  final Rx<ProfileType> profileType = ProfileType.user.obs;

  @override
  void onInit() {
    super.onInit();
    determineProfileType();
  }

  Future<void> determineProfileType() async {
    final user = _auth.authUser;
    if (user != null) {
      try {
        // Check if user is an admin
        final adminDoc = await _db.collection('Admins').doc(user.uid).get();
        if (adminDoc.exists) {
          profileType.value = ProfileType.admin;
          return;
        }

        // Check if user is a healthcare provider
        final healthcareDoc =
            await _db.collection('Healthcare').doc(user.uid).get();
        if (healthcareDoc.exists) {
          profileType.value = ProfileType.healthcare;
          return;
        }

        // Default to regular user
        profileType.value = ProfileType.user;
      } catch (e) {
        // In case of any error, default to regular user
        profileType.value = ProfileType.user;
      }
    }
  }
}
