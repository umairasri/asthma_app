import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:asthma_app/utils/logger.dart';
import '../models/event_model.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'Events';
  final String _healthcareCollection = 'Healthcare';

  Future<String> createEvent(EventModel event) async {
    try {
      // Validate that the healthcare document exists
      final healthcareDoc = await _firestore
          .collection(_healthcareCollection)
          .doc(event.healthcareId)
          .get();
      if (!healthcareDoc.exists) {
        TLogger.error(
            'Healthcare provider not found', 'ID: ${event.healthcareId}');
        throw Exception('Healthcare provider not found');
      }

      String? imageUrl;
      if (event.image != null) {
        try {
          // Upload image to Firebase Storage
          final ref = _storage.ref().child('event_images/${event.eventId}.jpg');
          await ref.putFile(File(event.image!));
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          TLogger.error('Failed to upload event image', e);
          // Continue without image if upload fails
        }
      }

      // Create event document with image URL
      final eventData = {
        ...event.toMap(),
        'image': imageUrl,
      };

      await _firestore
          .collection(_collection)
          .doc(event.eventId)
          .set(eventData);

      return event.eventId;
    } catch (e) {
      TLogger.error('Failed to create event', e);
      throw Exception('Failed to create event: $e');
    }
  }

  Future<List<EventModel>> getEventsByHealthcareId(String healthcareId) async {
    try {
      // Validate healthcare exists
      final healthcareDoc = await _firestore
          .collection(_healthcareCollection)
          .doc(healthcareId)
          .get();
      if (!healthcareDoc.exists) {
        throw Exception('Healthcare provider not found');
      }

      final snapshot = await _firestore
          .collection(_collection)
          .where('healthcareId', isEqualTo: healthcareId)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'eventId': doc.id}))
          .toList();

      // Sort the events in memory instead
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return events;
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (!doc.exists) {
        throw Exception('Event not found');
      }

      // Validate healthcare exists
      final eventData = doc.data()!;
      final healthcareId = eventData['healthcareId'] as String;
      final healthcareDoc = await _firestore
          .collection(_healthcareCollection)
          .doc(healthcareId)
          .get();
      if (!healthcareDoc.exists) {
        throw Exception('Healthcare provider not found');
      }

      return EventModel.fromMap({...eventData, 'eventId': doc.id});
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      // Validate healthcare exists
      final healthcareDoc = await _firestore
          .collection(_healthcareCollection)
          .doc(event.healthcareId)
          .get();
      if (!healthcareDoc.exists) {
        throw Exception('Healthcare provider not found');
      }

      String? imageUrl = event.image;
      if (event.image != null && event.image!.startsWith('/')) {
        // If it's a new local file, upload it
        final ref = _storage.ref().child('event_images/${event.eventId}.jpg');
        await ref.putFile(File(event.image!));
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection(_collection).doc(event.eventId).update({
        ...event.toMap(),
        'image': imageUrl,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> updateParticipantCount(String eventId, int newCount) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'currentParticipants': newCount,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update participant count: $e');
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'eventId': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  Future<Map<String, dynamic>> getHealthcareEventStatistics(
      String healthcareId) async {
    try {
      // Validate healthcare exists
      final healthcareDoc = await _firestore
          .collection(_healthcareCollection)
          .doc(healthcareId)
          .get();
      if (!healthcareDoc.exists) {
        throw Exception('Healthcare provider not found');
      }

      final snapshot = await _firestore
          .collection(_collection)
          .where('healthcareId', isEqualTo: healthcareId)
          .get();

      final events = snapshot.docs
          .map((doc) => EventModel.fromMap({...doc.data(), 'eventId': doc.id}))
          .toList();

      // Calculate statistics
      final now = DateTime.now();
      int totalEvents = events.length;
      int activeEvents = events.where((event) {
        final eventDate = _parseDate(event.date);
        return eventDate.isAfter(now);
      }).length;

      int totalParticipants =
          events.fold(0, (sum, event) => sum + event.currentParticipants);
      double averageParticipants =
          totalEvents > 0 ? totalParticipants / totalEvents : 0;

      // Calculate events by month for the last 5 months
      final eventsByMonth = <String, int>{};
      final months = <String>[];
      final currentDate = DateTime.now();

      // Generate last 5 months labels
      for (int i = 4; i >= 0; i--) {
        final date = DateTime(currentDate.year, currentDate.month - i, 1);
        final monthLabel = '${_getMonthAbbreviation(date.month)} ${date.year}';
        months.add(monthLabel);
        eventsByMonth[monthLabel] = 0;
      }

      // Count events for each month
      for (var event in events) {
        final eventDate = _parseDate(event.date);
        final monthLabel =
            '${_getMonthAbbreviation(eventDate.month)} ${eventDate.year}';
        if (eventsByMonth.containsKey(monthLabel)) {
          eventsByMonth[monthLabel] = (eventsByMonth[monthLabel] ?? 0) + 1;
        }
      }

      // Calculate participation rate distribution
      int fullyParticipatedEvents = 0;
      int partiallyParticipatedEvents = 0;

      for (var event in events) {
        if (event.currentParticipants >= event.numberOfParticipant) {
          fullyParticipatedEvents++;
        } else {
          partiallyParticipatedEvents++;
        }
      }

      final participationDistribution = [
        {
          'type': 'Fully Participated',
          'count': fullyParticipatedEvents,
          'percentage': totalEvents > 0
              ? (fullyParticipatedEvents / totalEvents * 100).round()
              : 0
        },
        {
          'type': 'Partially Participated',
          'count': partiallyParticipatedEvents,
          'percentage': totalEvents > 0
              ? (partiallyParticipatedEvents / totalEvents * 100).round()
              : 0
        }
      ];

      return {
        'totalEvents': totalEvents,
        'activeEvents': activeEvents,
        'totalParticipants': totalParticipants,
        'averageParticipants': averageParticipants,
        'eventsByMonth': months
            .map((month) => {
                  'month': month,
                  'count': eventsByMonth[month] ?? 0,
                })
            .toList(),
        'participantDistribution': participationDistribution,
      };
    } catch (e) {
      TLogger.error('Failed to get event statistics', e);
      throw Exception('Failed to get event statistics: $e');
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
