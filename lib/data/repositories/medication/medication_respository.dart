import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asthma_app/features/asthma/models/medication_model.dart';
import 'package:asthma_app/utils/logger.dart';

class MedicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch medications for a specific user
  Future<QuerySnapshot<Map<String, dynamic>>> fetchMedicationsForUser(
      String userId) async {
    TLogger.debug('Repository: Fetching medications for user: $userId');
    return await _firestore
        .collection('Medications')
        .where('userId', isEqualTo: userId)
        .get();
  }

  /// Save a new medication
  Future<String> saveMedication(MedicationModel medication) async {
    final docRef =
        await _firestore.collection('Medications').add(medication.toMap());
    return docRef.id;
  }

  /// Delete a medication
  Future<void> deleteMedication(String medicationId) async {
    await _firestore.collection('Medications').doc(medicationId).delete();
  }

  /// Update a medication
  Future<void> updateMedication(
      String medicationId, MedicationModel medication) async {
    await _firestore
        .collection('Medications')
        .doc(medicationId)
        .update(medication.toMap());
  }
}
