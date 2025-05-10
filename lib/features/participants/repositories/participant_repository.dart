import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant_model.dart';

class ParticipantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'Participants';

  Future<void> addParticipant(Participant participant) async {
    await _firestore
        .collection(collection)
        .doc(participant.participantId)
        .set(participant.toMap());
  }

  Future<Participant?> getParticipant(String participantId) async {
    final doc =
        await _firestore.collection(collection).doc(participantId).get();
    if (doc.exists) {
      return Participant.fromMap(doc.data()!);
    }
    return null;
  }

  Future<List<Participant>> getParticipantsByEvent(String eventId) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('eventId', isEqualTo: eventId)
        .get();

    return querySnapshot.docs
        .map((doc) => Participant.fromMap(doc.data()))
        .toList();
  }

  Future<List<Participant>> getParticipantsByDependent(
      String dependentId) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('dependentId', isEqualTo: dependentId)
        .get();

    return querySnapshot.docs
        .map((doc) => Participant.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateParticipant(Participant participant) async {
    await _firestore
        .collection(collection)
        .doc(participant.participantId)
        .update(participant.toMap());
  }

  Future<void> deleteParticipant(String participantId) async {
    await _firestore.collection(collection).doc(participantId).delete();
  }

  Stream<List<Participant>> getParticipantsStream() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Participant.fromMap(doc.data()))
          .toList();
    });
  }
}
