import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model class representing a symptom.
class SymptomModel {
  final String id;
  final List<Map<String, String>> symptom;
  final String userId;
  final String date; // formatted: yyyy-MM-dd
  final String time; // formatted: h:mm AM/PM

  SymptomModel({
    required this.id,
    required this.symptom,
    required this.userId,
    required this.date,
    required this.time,
  });

  /// Convert TimeOfDay to formatted string like "2:00 PM"
  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final localTime = TimeOfDay.fromDateTime(dateTime);
    final hour = localTime.hourOfPeriod == 0 ? 12 : localTime.hourOfPeriod;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = localTime.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  /// Format DateTime to yyyy-MM-dd
  static String formatDate(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')}";
  }

  factory SymptomModel.fromMap(Map<String, dynamic> map, String docId) {
    return SymptomModel(
      id: docId,
      symptom: (map['symptom'] as List)
          .map((e) => Map<String, String>.from(e as Map<String, dynamic>))
          .toList(),
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symptom': symptom,
      'userId': userId,
      'date': date,
      'time': time,
    };
  }

  factory SymptomModel.fromSnapshot(DocumentSnapshot snapshot) {
    return SymptomModel.fromMap(
        snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  SymptomModel copyWith({
    String? id,
    List<Map<String, String>>? symptom,
    String? userId,
    String? date,
    String? time,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      symptom: symptom ?? this.symptom,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}
