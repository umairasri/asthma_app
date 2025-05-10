import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String healthcareId;
  final String eventName;
  final String time;
  final String date;
  final String location;
  final String details;
  final int numberOfParticipant;
  final int currentParticipants;
  final String? image;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  EventModel({
    required this.eventId,
    required this.healthcareId,
    required this.eventName,
    required this.time,
    required this.date,
    required this.location,
    required this.details,
    required this.numberOfParticipant,
    this.currentParticipants = 0,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'healthcareId': healthcareId,
      'eventName': eventName,
      'time': time,
      'date': date,
      'location': location,
      'details': details,
      'numberOfParticipant': numberOfParticipant,
      'currentParticipants': currentParticipants,
      'image': image,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['eventId'] ?? '',
      healthcareId: map['healthcareId'] ?? '',
      eventName: map['eventName'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      details: map['details'] ?? '',
      numberOfParticipant: map['numberOfParticipant']?.toInt() ?? 0,
      currentParticipants: map['currentParticipants']?.toInt() ?? 0,
      image: map['image'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}
