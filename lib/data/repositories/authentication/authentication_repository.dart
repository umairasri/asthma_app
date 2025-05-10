import 'package:asthma_app/data/repositories/patient/patient_repository.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_navigation_menu.dart';
import 'package:asthma_app/features/authentication/screens/login/login.dart';
import 'package:asthma_app/features/authentication/screens/onboarding/onboarding.dart';
import 'package:asthma_app/features/authentication/screens/signup/verify_email.dart';
import 'package:asthma_app/features/authentication/screens/waiting_approval/waiting_approval_screen.dart';
import 'package:asthma_app/features/asthma/screens/admin_page/admin_navigation_menu.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_home_page.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/navigation_menu.dart';
import 'package:asthma_app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:asthma_app/utils/exceptions/firebase_exceptions.dart';
import 'package:asthma_app/utils/exceptions/format_exceptions.dart';
import 'package:asthma_app/utils/exceptions/platform_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  /// Called from main.dart on app launch
  @override
  void onReady() {
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  /// Check if the user is an admin
  Future<bool> _isAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('Admins').doc(userId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) print('Error checking admin: $e');
      return false;
    }
  }

  /// Function to Show Relevant Screen and redirect accordingly
  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      // Check if user is an admin
      final isAdmin = await _isAdmin(user.uid);
      if (isAdmin) {
        Get.offAll(() => const AdminNavigationMenu());
        return;
      }

      // Check if user is a healthcare provider
      final isHealthcareProvider = await _isHealthcareProvider(user.uid);

      if (isHealthcareProvider) {
        // Check if healthcare provider is approved
        final isApproved = await _isHealthcareApproved(user.uid);

        if (isApproved) {
          // If approved, navigate to healthcare home page
          Get.offAll(() => const HealthcareNavigationMenu());
        } else {
          // If not approved, navigate to waiting approval screen
          Get.offAll(() => const WaitingApprovalScreen());
        }
        return;
      }

      // For regular users, check email verification
      if (user.emailVerified) {
        Get.offAll(() => const NavigationMenu());
      } else {
        // If the user's email is not verified, navigate to the VerifyEmailScreen
        Get.offAll(() => VerifyEmailScreen(email: _auth.currentUser?.email));
      }
    } else {
      // Local Storage
      if (kDebugMode) {
        print('========== GET STORAGE Auth Repo ==========');
        print(deviceStorage.read('IsFirstTime'));
      }
      // Local Storage
      deviceStorage.writeIfNull('IsFirstTime', true);

      // Check if it's the first time lauching the app
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() =>
              const LoginScreen()) // Redirect to Login Screen if not the first time
          : Get.offAll(
              const OnBoardingScreen()); // Redirect to OnBoarding Screen if it's the first time
    }
  }

  /// Check if the user is a healthcare provider
  Future<bool> _isHealthcareProvider(String userId) async {
    try {
      final doc = await _firestore.collection('Healthcare').doc(userId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) print('Error checking healthcare provider: $e');
      return false;
    }
  }

  /// Check if the healthcare provider is approved
  Future<bool> _isHealthcareApproved(String userId) async {
    try {
      final doc = await _firestore.collection('Healthcare').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['IsApproved'] ?? false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('Error checking healthcare approval: $e');
      return false;
    }
  }

  /* ----------- Email & Password sign-in --------------*/

  /// [EmailAuthentication] - LOGIN
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [ReAuthenticate] - RE AUTHENTICATE USER
  Future<void> reAuthenticateWithEmailAndPassword(
      String email, String password) async {
    try {
      // Create a credential
      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);

      // ReAuthenticate
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// [EmailVerification] - MAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong, Please try again';
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong, Please try again';
    }
  }

  /* ----------- Federated identity & social sign-in --------------*/
  /// [GoogleAuthentication] - GOOGLE
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await userAccount?.authentication;

      // Create a new credential
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credentials);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      if (kDebugMode) print('Something went wrong: $e');
      return null;
    }
  }

  /* ----------- ./end Federated identity & social sign-in --------------*/
  /// [LogoutUser] - Valid for any authentication
  Future<void> logout() async {
    try {
      // Clear user data before signing out
      final userController = Get.find<PatientController>();
      userController.clearUserData();

      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// DELETE USER - Remove user Auth and Firestore Account
  Future<void> deleteAccount() async {
    try {
      await PatientRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
