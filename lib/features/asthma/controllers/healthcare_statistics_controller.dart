import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthcareStatisticsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final RxInt totalEvents = 0.obs;
  final RxInt totalParticipants = 0.obs;
  final RxInt activeEvents = 0.obs;
  final RxDouble averageParticipants = 0.0.obs;
  final RxList<Map<String, dynamic>> eventsByYear =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> participantDistribution =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      // Fetch all events
      final eventsSnapshot = await _firestore.collection('Events').get();
      final events = eventsSnapshot.docs;

      // Calculate total events
      totalEvents.value = events.length;

      // Calculate active events (events that haven't ended yet)
      final now = DateTime.now();
      activeEvents.value = events.where((event) {
        final endDate = (event.data()['endDate'] as Timestamp).toDate();
        return endDate.isAfter(now);
      }).length;

      // Calculate events by year
      final eventsByYearMap = <String, int>{};
      for (var event in events) {
        final date = (event.data()['startDate'] as Timestamp).toDate();
        final year = date.year.toString();
        eventsByYearMap[year] = (eventsByYearMap[year] ?? 0) + 1;
      }

      eventsByYear.value = eventsByYearMap.entries
          .map((e) => {'year': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (a['year'] as String).compareTo(b['year'] as String));

      // Fetch participants for each event
      int totalParticipantsCount = 0;
      final participantCounts = <String, int>{};

      for (var event in events) {
        final participantsSnapshot = await _firestore
            .collection('Events')
            .doc(event.id)
            .collection('Participants')
            .get();

        final participantCount = participantsSnapshot.docs.length;
        totalParticipantsCount += participantCount;

        // Get event type for distribution
        final eventType = event.data()['type'] ?? 'Other';
        participantCounts[eventType] =
            (participantCounts[eventType] ?? 0) + participantCount;
      }

      // Calculate total participants and average
      totalParticipants.value = totalParticipantsCount;
      averageParticipants.value = totalEvents.value > 0
          ? totalParticipantsCount / totalEvents.value
          : 0.0;

      // Calculate participant distribution
      participantDistribution.value = participantCounts.entries
          .map((e) => {
                'type': e.key,
                'count': e.value,
                'percentage': (e.value / totalParticipantsCount * 100).round()
              })
          .toList();
    } catch (e) {
      print('Error fetching statistics: $e');
      // You might want to show an error message to the user here
    }
  }
}
