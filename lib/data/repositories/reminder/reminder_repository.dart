import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asthma_app/features/reminder/models/reminder_model.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';

class ReminderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReminder(ReminderModel reminder) async {
    await _db.collection("Reminders").doc(reminder.id).set(reminder.toJson());
  }

  Stream<List<ReminderModel>> getUserReminders() {
    final uid = AuthenticationRepository.instance.authUser?.uid;
    return _db
        .collection("Reminders")
        .where("userId", isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromSnapshot(doc))
            .toList());
  }
}
