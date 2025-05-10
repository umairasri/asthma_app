import 'package:asthma_app/data/repositories/symptom/symptom_respository.dart';
import 'package:asthma_app/features/asthma/models/symptom_model.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/logger.dart';

class SymptomController extends GetxController {
  static SymptomController get instance => Get.find();

  RxList<SymptomModel> symptoms = <SymptomModel>[].obs;
  RxBool loadingSymptoms = false.obs;

  final SymptomRepository symptomRepository = Get.put(SymptomRepository());
  final PatientController userController = Get.put(PatientController());
  final SelectedDependentController selectedDependentController =
      Get.put(SelectedDependentController());

  @override
  void onInit() {
    super.onInit();
    fetchSymptoms();

    // Listen for changes in the selected dependent
    ever(selectedDependentController.selectedUserId, (_) {
      fetchSymptoms();
    });
  }

  Future<void> fetchSymptoms() async {
    try {
      loadingSymptoms.value = true;
      final userId = selectedDependentController.getSelectionUserId();
      TLogger.debug('Fetching symptoms for user/dependent: $userId');

      if (userId.isNotEmpty) {
        final snapshot = await symptomRepository.fetchSymptomsForUser(userId);
        symptoms.value =
            snapshot.docs.map((doc) => SymptomModel.fromSnapshot(doc)).toList();
        TLogger.debug('Fetched ${symptoms.length} symptoms');
      } else {
        TLogger.warning('User ID is empty, cannot fetch symptoms');
      }
    } catch (e, stackTrace) {
      symptoms.clear();
      TLogger.error('Error fetching symptoms', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error fetching symptoms", message: e.toString());
    } finally {
      loadingSymptoms.value = false;
    }
  }

  Future<void> addSymptom(SymptomModel symptomModel) async {
    try {
      loadingSymptoms.value = true;
      final userId = selectedDependentController.getSelectionUserId();
      if (userId.isNotEmpty) {
        // Create a new symptom model with the current user/dependent ID
        final newSymptomModel = symptomModel.copyWith(userId: userId);
        final newId = await symptomRepository.saveSymptom(newSymptomModel);
        final savedSymptom = newSymptomModel.copyWith(id: newId);
        symptoms.add(savedSymptom);
        TLogger.debug('Added symptom for user/dependent: $userId');
      }
    } catch (e, stackTrace) {
      TLogger.error('Error adding symptom', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error adding symptom", message: e.toString());
    } finally {
      loadingSymptoms.value = false;
    }
  }

  Future<void> updateSymptom({
    required String symptomId,
    required List<Map<String, String>> symptomList,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      loadingSymptoms.value = true;
      final userId = selectedDependentController.getSelectionUserId();

      final updatedSymptom = SymptomModel(
        id: symptomId,
        symptom: symptomList,
        userId: userId,
        date: SymptomModel.formatDate(date),
        time: SymptomModel.formatTime(time),
      );

      await symptomRepository.updateSymptom(symptomId, updatedSymptom);
      final index = symptoms.indexWhere((s) => s.id == symptomId);
      if (index != -1) {
        symptoms[index] = updatedSymptom;
      }
      TLogger.debug('Updated symptom for user/dependent: $userId');
    } catch (e, stackTrace) {
      TLogger.error('Error updating symptom', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error updating symptom", message: e.toString());
    } finally {
      loadingSymptoms.value = false;
    }
  }

  Future<void> deleteSymptom(String symptomId) async {
    try {
      loadingSymptoms.value = true;
      await symptomRepository.deleteSymptom(symptomId);
      symptoms.removeWhere((s) => s.id == symptomId);
      TLogger.debug('Deleted symptom: $symptomId');
    } catch (e, stackTrace) {
      TLogger.error('Error deleting symptom', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error deleting symptom", message: e.toString());
    } finally {
      loadingSymptoms.value = false;
    }
  }
}
