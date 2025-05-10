import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing administrator data.
class AdminModel {
  final String id;
  final String userId; // Link to UserModel
  final String firstName;
  final String lastName;
  String profilePicture;

  /// Constructor for AdminModel.
  AdminModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.profilePicture = '',
  });

  /// Static function to create an empty admin model.
  static AdminModel empty() => AdminModel(
        id: '',
        userId: '',
        firstName: '',
        lastName: '',
        profilePicture: '',
      );

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'ProfilePicture': profilePicture,
    };
  }

  /// Factory method to create an AdminModel from a Firebase document snapshot.
  factory AdminModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return AdminModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
      );
    } else {
      return AdminModel.empty();
    }
  }
}
