import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant_model.dart';
import '../repositories/participant_repository.dart';

class ParticipantController extends GetxController {
  final ParticipantRepository _repository = ParticipantRepository();
  final RxList<Participant> participants = <Participant>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    try {
      isLoading.value = true;
      _repository.getParticipantsStream().listen((data) {
        participants.value = data;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch participants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addParticipant({
    required String dependentId,
    required String eventId,
  }) async {
    try {
      isLoading.value = true;
      final now = Timestamp.now();
      final participant = Participant(
        participantId:
            FirebaseFirestore.instance.collection('Participants').doc().id,
        dependentId: dependentId,
        eventId: eventId,
        timeJoin: now.toDate(),
        dateJoin: now.toDate(),
      );
      await _repository.addParticipant(participant);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add participant: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Participant>> getParticipantsByEvent(String eventId) async {
    try {
      isLoading.value = true;
      return await _repository.getParticipantsByEvent(eventId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get participants by event: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Participant>> getParticipantsByDependent(
      String dependentId) async {
    try {
      isLoading.value = true;
      return await _repository.getParticipantsByDependent(dependentId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get participants by dependent: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteParticipant(String participantId) async {
    try {
      isLoading.value = true;
      await _repository.deleteParticipant(participantId);
      Get.snackbar('Success', 'Participant deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete participant: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
