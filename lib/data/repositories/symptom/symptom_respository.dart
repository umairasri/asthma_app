import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asthma_app/features/asthma/models/symptom_model.dart';
import 'package:asthma_app/utils/logger.dart';

class SymptomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch symptoms for a specific user
  Future<QuerySnapshot<Map<String, dynamic>>> fetchSymptomsForUser(
      String userId) async {
    return await _firestore
        .collection('Symptoms')
        .where('userId', isEqualTo: userId)
        .get();
  }

  /// Save a new symptom
  Future<String> saveSymptom(SymptomModel symptom) async {
    final docRef = await _firestore.collection('Symptoms').add(symptom.toMap());
    return docRef.id;
  }

  /// Delete a symptom
  Future<void> deleteSymptom(String symptomId) async {
    await _firestore.collection('Symptoms').doc(symptomId).delete();
  }

  /// Update a symptom
  Future<void> updateSymptom(String symptomId, SymptomModel symptom) async {
    await _firestore
        .collection('Symptoms')
        .doc(symptomId)
        .update(symptom.toMap());
  }
}
