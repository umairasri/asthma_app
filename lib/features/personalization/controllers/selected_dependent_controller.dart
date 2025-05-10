import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedDependentController extends GetxController {
  static SelectedDependentController get instance => Get.find();

  // Store the currently selected dependent or null if the user is recording for themselves
  final Rx<DependentModel?> selectedDependent = Rx<DependentModel?>(null);

  // Store the user ID for the current selection (either the user's ID or the dependent's ID)
  final RxString selectedUserId = ''.obs;

  // Store the name for display purposes
  final RxString selectedName = ''.obs;

  // Store the profile picture for display purposes
  final RxString selectedProfilePicture = ''.obs;

  // Store the type of selection (user or dependent)
  final RxString selectionType = 'user'.obs;

  // Keys for SharedPreferences
  static const String _lastSelectedTypeKey = 'last_selected_type';
  static const String _lastSelectedIdKey = 'last_selected_id';

  // Store SharedPreferences instance
  SharedPreferences? _prefs;

  // Flag to track initialization
  bool _isInitialized = false;

  // Flag to track if initialization is complete
  final RxBool isInitializationComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      _initializeSharedPreferences();
      _isInitialized = true;
    }
    _initPrefs();
    // Listen for changes in user data
    ever(Get.find<PatientController>().user, (_) {
      if (selectionType.value == 'user') {
        selectUser(); // Update the selection when user data changes
      }
    });
  }

  Future<void> _initializeSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Initialize with the last selected dependent or user
      await _initializeSelection();
      isInitializationComplete.value = true;
    } catch (e) {
      TLogger.error('Failed to initialize SharedPreferences', e);
      // If SharedPreferences fails, default to user selection
      _selectUser();
      isInitializationComplete.value = true;
    }

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // When a new user logs in, initialize with last selection
        Future.microtask(() => _initializeSelection());
      }
    });

    // Add a listener to ensure the user is always selected when the app starts
    ever(selectedUserId, (String userId) {
      if (userId.isEmpty) {
        TLogger.debug('User ID is empty, selecting default user');
        Future.microtask(() => _selectUser());
      }
    });
  }

  // Initialize selection based on last saved state
  Future<void> _initializeSelection() async {
    if (_prefs == null) {
      TLogger.warning(
          'SharedPreferences not initialized, defaulting to user selection');
      _selectUser();
      return;
    }

    try {
      final lastSelectedType =
          _prefs!.getString(_lastSelectedTypeKey) ?? 'user';
      final lastSelectedId = _prefs!.getString(_lastSelectedIdKey) ?? '';

      if (lastSelectedType == 'user') {
        _selectUser();
      } else {
        final dependentController = Get.find<DependentController>();
        await dependentController.fetchUserDependents();
        final dependent = dependentController.dependents.firstWhere(
          (d) => d.id == lastSelectedId,
          orElse: () => DependentModel(
            id: '',
            userId: '',
            name: '',
            gender: '',
            dateOfBirth: '',
            profilePicture: '',
            relation: '',
            dailyMedicationUsage: '',
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
          ),
        );
        if (dependent.id?.isNotEmpty == true) {
          selectDependent(dependent);
        } else {
          _selectUser();
        }
      }
    } catch (e) {
      TLogger.error('Failed to initialize selection', e);
      _selectUser();
    }
  }

  // Select the current user (patient)
  void _selectUser() async {
    final userController = Get.find<PatientController>();
    if (userController.user.value.id.isNotEmpty) {
      // Create a DependentModel for the user to maintain consistency
      selectedDependent.value = DependentModel(
        id: userController.user.value.id,
        userId: userController.user.value.id,
        name: userController.user.value.username,
        gender: userController.user.value.gender,
        dateOfBirth: userController.user.value.dateOfBirth,
        profilePicture: userController.user.value.profilePicture,
        relation: 'Main Account',
        dailyMedicationUsage: userController.user.value.dailyMedicationUsage,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      selectedUserId.value = userController.user.value.id;
      selectedName.value = userController.user.value.username;
      selectedProfilePicture.value = userController.user.value.profilePicture;
      selectionType.value = 'user';

      // Save selection to SharedPreferences
      if (_prefs != null) {
        try {
          await _prefs!.setString(_lastSelectedTypeKey, 'user');
          await _prefs!
              .setString(_lastSelectedIdKey, userController.user.value.id);
        } catch (e) {
          TLogger.error(
              'Failed to save user selection to SharedPreferences', e);
        }
      }

      TLogger.debug(
          'Selected user: ${selectedName.value} (${selectedUserId.value})');
    }
  }

  // Select a dependent
  void selectDependent(DependentModel dependent) async {
    if (dependent.id?.isNotEmpty == true) {
      selectedDependent.value = dependent;
      selectedUserId.value = dependent.id ?? '';
      selectedName.value = dependent.name ?? '';
      selectedProfilePicture.value = dependent.profilePicture ?? '';
      selectionType.value = 'dependent';

      // Save selection to SharedPreferences
      if (_prefs != null) {
        try {
          await _prefs!.setString(_lastSelectedTypeKey, 'dependent');
          await _prefs!.setString(_lastSelectedIdKey, dependent.id ?? '');
        } catch (e) {
          TLogger.error(
              'Failed to save dependent selection to SharedPreferences', e);
        }
      }

      TLogger.debug(
          'Selected dependent: ${selectedName.value} (${selectedUserId.value})');
    }
  }

  // Select the user (patient)
  void selectUser() async {
    final userController = Get.find<PatientController>();
    if (userController.user.value.id.isNotEmpty) {
      // Create a DependentModel for the user to maintain consistency
      selectedDependent.value = DependentModel(
        id: userController.user.value.id,
        userId: userController.user.value.id,
        name: userController.user.value.username,
        gender: userController.user.value.gender,
        dateOfBirth: userController.user.value.dateOfBirth,
        profilePicture: userController.user.value.profilePicture,
        relation: 'Main Account',
        dailyMedicationUsage: userController.user.value.dailyMedicationUsage,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      selectedUserId.value = userController.user.value.id;
      selectedName.value = userController.user.value.username;
      selectedProfilePicture.value = userController.user.value.profilePicture;
      selectionType.value = 'user';

      // Save selection to SharedPreferences
      if (_prefs != null) {
        try {
          await _prefs!.setString(_lastSelectedTypeKey, 'user');
          await _prefs!
              .setString(_lastSelectedIdKey, userController.user.value.id);
        } catch (e) {
          TLogger.error(
              'Failed to save user selection to SharedPreferences', e);
        }
      }

      TLogger.debug(
          'Selected user: ${selectedName.value} (${selectedUserId.value})');
    }
  }

  // Get the current selection type
  String getSelectionType() {
    return selectionType.value;
  }

  // Get the current selection name
  String getSelectionName() {
    return selectedName.value;
  }

  // Get the current selection profile picture
  String getSelectionProfilePicture() {
    return selectedProfilePicture.value;
  }

  // Get the current selection user ID
  String getSelectionUserId() {
    return selectedUserId.value;
  }

  // Check if the current selection is valid
  bool isSelectionValid() {
    if (selectionType.value == 'user') {
      return selectedUserId.value.isNotEmpty;
    } else {
      return selectedDependent.value?.id?.isNotEmpty == true;
    }
  }

  // Refresh the current selection
  Future<void> refreshSelection() async {
    if (selectionType.value == 'user') {
      _selectUser();
    } else if (selectedDependent.value?.id?.isNotEmpty == true) {
      final dependentController = Get.find<DependentController>();
      await dependentController.fetchUserDependents();
      final dependent = dependentController.dependents.firstWhere(
        (d) => d.id == selectedDependent.value?.id,
        orElse: () => DependentModel(
          id: '',
          userId: '',
          name: '',
          gender: '',
          dateOfBirth: '',
          profilePicture: '',
          relation: '',
          dailyMedicationUsage: '',
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        ),
      );
      if (dependent.id?.isNotEmpty == true) {
        selectDependent(dependent);
      } else {
        _selectUser();
      }
    }
  }

  // Wait for initialization to complete
  Future<void> waitForInitialization() async {
    if (!isInitializationComplete.value) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return !isInitializationComplete.value;
      });
    }
  }

  // Get the last selected type from SharedPreferences
  String? getLastSelectedType() {
    return _prefs?.getString(_lastSelectedTypeKey);
  }

  // Get the last selected ID from SharedPreferences
  String? getLastSelectedId() {
    return _prefs?.getString(_lastSelectedIdKey);
  }

  void _initPrefs() {
    // Implementation of _initPrefs method
  }
}
