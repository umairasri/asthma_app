import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { healthcare, patient, admin }

class UserModel {
  final String userId;
  final String email;
  final String? password; // Note: Password should not be stored in Firestore
  final UserRole role; // Role is final and cannot be changed

  UserModel({
    required this.userId,
    required this.email,
    this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Email': email,
      'Role': role.toString().split('.').last,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['UserId'] ?? '',
      email: json['Email'] ?? '',
      role: UserRole.values.firstWhere(
        (role) =>
            role.toString().split('.').last.toLowerCase() ==
            (json['Role']?.toString().toLowerCase() ?? 'patient'),
        orElse: () => UserRole.patient,
      ),
    );
  }
}
