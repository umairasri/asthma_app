import 'package:cloud_firestore/cloud_firestore.dart';

class DependentModel {
  final String id;
  final String userId; // ID of the parent/patient user
  final String name;
  final String gender;
  final String dateOfBirth;
  final String profilePicture;
  final String relation; // e.g., "Child", "Parent", "Grandparent"
  final String evohaler; // Number of daily medication usage
  final Timestamp createdAt;
  final Timestamp updatedAt;

  DependentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.profilePicture,
    required this.relation,
    required this.evohaler,
    required this.createdAt,
    required this.updatedAt,
  });

  // Empty constructor
  factory DependentModel.empty() {
    return DependentModel(
      id: '',
      userId: '',
      name: '',
      gender: '',
      dateOfBirth: '',
      profilePicture: '',
      relation: '',
      evohaler: '0',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'profilePicture': profilePicture,
      'relation': relation,
      'evohaler': evohaler,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create model from JSON
  factory DependentModel.fromJson(Map<String, dynamic> json) {
    return DependentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      relation: json['relation'] ?? '',
      evohaler: json['evohaler'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  // Create a copy of the model with some fields updated
  DependentModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? gender,
    String? dateOfBirth,
    String? profilePicture,
    String? relation,
    String? evohaler,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return DependentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profilePicture: profilePicture ?? this.profilePicture,
      relation: relation ?? this.relation,
      evohaler: evohaler ?? this.evohaler,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
