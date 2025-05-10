import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Model class representing a medication.
class MedicationModel {
  final String id;
  final List<Map<String, String>> medication;
  final String userId;
  final String date; // formatted: yyyy-MM-dd
  final String time; // formatted: h:mm AM/PM

  MedicationModel({
    required this.id,
    required this.medication,
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

  factory MedicationModel.fromMap(Map<String, dynamic> map, String docId) {
    // Handle both 'medication' and 'medications' field names
    final medicationList = map['medication'] ?? map['medications'];

    return MedicationModel(
      id: docId,
      medication: (medicationList as List?)
              ?.map((e) => Map<String, String>.from(e as Map<String, dynamic>))
              .toList() ??
          [],
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medication': medication,
      'userId': userId,
      'date': date,
      'time': time,
    };
  }

  factory MedicationModel.fromSnapshot(DocumentSnapshot snapshot) {
    return MedicationModel.fromMap(
        snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  MedicationModel copyWith({
    String? id,
    List<Map<String, String>>? medication,
    String? userId,
    String? date,
    String? time,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      medication: medication ?? this.medication,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}
