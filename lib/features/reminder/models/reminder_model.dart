import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String color;
  final String time;
  final String date;
  final String repeat;
  final String ringtone;
  final String details;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.color,
    required this.time,
    required this.date,
    required this.repeat,
    required this.ringtone,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'color': color,
        'time': time,
        'date': date,
        'repeat': repeat,
        'ringtone': ringtone,
        'details': details,
      };

  factory ReminderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: data['id'],
      userId: data['userId'],
      title: data['title'],
      color: data['color'],
      time: data['time'],
      date: data['date'],
      repeat: data['repeat'],
      ringtone: data['ringtone'],
      details: data['details'],
    );
  }
}
