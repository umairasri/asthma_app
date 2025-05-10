import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';
import 'package:asthma_app/data/repositories/admin/admin_repository.dart';
import 'package:asthma_app/features/asthma/controllers/medication_controller.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/events/controllers/event_controller.dart';
import 'package:asthma_app/features/participants/controllers/participant_controller.dart';
import 'package:asthma_app/features/notification/noti_service.dart';
import 'package:asthma_app/features/personalization/controllers/admin_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/user_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:asthma_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/instance_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';

/// -- Entry point of Flutter App
Future<void> main() async {
  /// Widgets Binding
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // init notifications
  NotiService().initNotification();

  /// -- GetX Local Storage
  await GetStorage.init();

  // Todo: Init Payment Methods

  /// -- Await Splash until other items Load
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- Initialize Firebase & Authentication Repository
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then(
    (FirebaseApp value) {
      Get.put(AuthenticationRepository()); // Register AuthenticationRepository
      Get.put(AdminRepository()); // Register AdminRepository
      Get.put(AdminController()); // Register AdminController
      Get.put(SymptomController()); // Register SymptomController
      Get.put(MedicationController()); // Register MedicationController
      Get.put(
          SelectedDependentController()); // Register SelectedDependentController
      Get.put(UserController()); // Register UserController
      Get.put(EventController()); // Register EventController
      Get.put(ParticipantController()); // Register ParticipantController

      // Create default admin account if it doesn't exist
      try {
        AdminRepository.instance.createDefaultAdminAccount();
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing default admin: $e');
        }
      }
    },
  );

  // Load all the Material Design / Themes / Localizations / Bindings
  runApp(const App());
}
