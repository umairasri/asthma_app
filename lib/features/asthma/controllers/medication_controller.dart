import 'package:asthma_app/data/repositories/medication/medication_respository.dart';
import 'package:asthma_app/features/asthma/models/medication_model.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/logger.dart';

class MedicationController extends GetxController {
  static MedicationController get instance => Get.find();

  RxList<MedicationModel> medications = <MedicationModel>[].obs;
  RxBool loadingMedications = false.obs;

  final MedicationRepository medicationRepository =
      Get.put(MedicationRepository());
  final PatientController userController = Get.put(PatientController());
  final SelectedDependentController selectedDependentController =
      Get.put(SelectedDependentController());

  @override
  void onInit() {
    super.onInit();
    fetchMedications();

    // Listen for changes in the selected dependent
    ever(selectedDependentController.selectedUserId, (_) {
      fetchMedications();
    });
  }

  Future<void> fetchMedications() async {
    try {
      loadingMedications.value = true;
      final userId = selectedDependentController.getSelectionUserId();
      TLogger.debug('Fetching medications for user/dependent: $userId');

      if (userId.isNotEmpty) {
        final snapshot =
            await medicationRepository.fetchMedicationsForUser(userId);

        // Clear existing medications before adding new ones
        medications.clear();

        // Process each document with error handling
        for (var doc in snapshot.docs) {
          try {
            final medication = MedicationModel.fromSnapshot(doc);
            medications.add(medication);
          } catch (e, stackTrace) {
            TLogger.error('Error processing medication document: ${doc.id}', e,
                stackTrace);
            // Continue processing other documents
          }
        }

        TLogger.debug('Fetched ${medications.length} medications');
      } else {
        TLogger.warning('User ID is empty, cannot fetch medications');
      }
    } catch (e, stackTrace) {
      medications.clear();
      TLogger.error('Error fetching medications', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error fetching medications", message: e.toString());
    } finally {
      loadingMedications.value = false;
    }
  }

  Future<void> addMedication(MedicationModel medicationModel) async {
    try {
      loadingMedications.value = true;
      final userId = selectedDependentController.getSelectionUserId();
      if (userId.isNotEmpty) {
        // Create a new medication model with the current user/dependent ID
        final newMedicationModel = medicationModel.copyWith(userId: userId);
        final newId =
            await medicationRepository.saveMedication(newMedicationModel);
        final savedMedication = newMedicationModel.copyWith(id: newId);
        medications.add(savedMedication);
        TLogger.debug('Added medication for user/dependent: $userId');
      }
    } catch (e, stackTrace) {
      TLogger.error('Error adding medication', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error adding medications", message: e.toString());
    } finally {
      loadingMedications.value = false;
    }
  }

  Future<void> updateMedication({
    required String medicationId,
    required List<Map<String, String>> medicationList,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      loadingMedications.value = true;
      final userId = selectedDependentController.getSelectionUserId();

      final updatedMedication = MedicationModel(
        id: medicationId,
        medication: medicationList,
        userId: userId,
        date: MedicationModel.formatDate(date),
        time: MedicationModel.formatTime(time),
      );

      await medicationRepository.updateMedication(
          medicationId, updatedMedication);
      final index = medications.indexWhere((s) => s.id == medicationId);
      if (index != -1) {
        medications[index] = updatedMedication;
      }
      TLogger.debug('Updated medication for user/dependent: $userId');
    } catch (e, stackTrace) {
      TLogger.error('Error updating medication', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error updating medication", message: e.toString());
    } finally {
      loadingMedications.value = false;
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      loadingMedications.value = true;
      await medicationRepository.deleteMedication(medicationId);
      medications.removeWhere((s) => s.id == medicationId);
      TLogger.debug('Deleted medication: $medicationId');
    } catch (e, stackTrace) {
      TLogger.error('Error deleting medication', e, stackTrace);
      TLoaders.errorSnackBar(
          title: "Error deleting medication", message: e.toString());
    } finally {
      loadingMedications.value = false;
    }
  }
}
