import 'package:get/get.dart';
import 'package:asthma_app/data/repositories/user/user_repository.dart';
import 'package:asthma_app/features/personalization/models/user_model.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final userRepository = Get.put(UserRepository());
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // Initialize with current user data
    _initializeUserData();

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _initializeUserData();
      } else {
        clearUserData();
      }
    });
  }

  Future<void> _initializeUserData() async {
    final user = AuthenticationRepository.instance.authUser;
    if (user != null) {
      await initUser(user.uid);
    }
  }

  /// Initialize user data
  Future<void> initUser(String userId) async {
    try {
      final user = await userRepository.getUserById(userId);
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Create a new user with role
  Future<void> createUserWithRole(
      String userId, String email, UserRole role) async {
    try {
      final user = UserModel(
        userId: userId,
        email: email,
        role: role,
      );
      await userRepository.createUser(user);
      currentUser.value = user;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Get current user role
  UserRole? getCurrentUserRole() {
    return currentUser.value?.role;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return currentUser.value?.email;
  }

  /// Check if user has specific role
  bool hasRole(UserRole role) {
    return currentUser.value?.role == role;
  }

  /// Clear current user data
  void clearUserData() {
    currentUser.value = null;
  }
}
