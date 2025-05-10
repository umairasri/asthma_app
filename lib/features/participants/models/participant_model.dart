import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String participantId;
  final String dependentId;
  final String eventId;
  final DateTime timeJoin;
  final DateTime dateJoin;

  Participant({
    required this.participantId,
    required this.dependentId,
    required this.eventId,
    required this.timeJoin,
    required this.dateJoin,
  });

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'dependentId': dependentId,
      'eventId': eventId,
      'timeJoin': Timestamp.fromDate(timeJoin),
      'dateJoin': Timestamp.fromDate(dateJoin),
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      participantId: map['participantId'] as String? ?? '',
      dependentId: map['dependentId'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      timeJoin: (map['timeJoin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateJoin: (map['dateJoin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Participant copyWith({
    String? participantId,
    String? dependentId,
    String? eventId,
    DateTime? timeJoin,
    DateTime? dateJoin,
  }) {
    return Participant(
      participantId: participantId ?? this.participantId,
      dependentId: dependentId ?? this.dependentId,
      eventId: eventId ?? this.eventId,
      timeJoin: timeJoin ?? this.timeJoin,
      dateJoin: dateJoin ?? this.dateJoin,
    );
  }
}
