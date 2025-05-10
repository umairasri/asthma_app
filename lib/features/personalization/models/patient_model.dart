import 'package:asthma_app/utils/formatters/formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing patient data.
class PatientModel {
  final String id;
  final String userId; // Link to UserModel
  String username;
  String firstName;
  String lastName;
  String phoneNumber;
  String profilePicture;
  String gender;
  String dateOfBirth;
  String dailyMedicationUsage; // Number of daily medication usage

  /// Constructor for UserModel.
  PatientModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.gender,
    required this.dateOfBirth,
    required this.dailyMedicationUsage,
  });

  /// Helper function to get the full name.
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone number
  String get formattedPhoneNumber => TFormatter.formatPhoneNumber(phoneNumber);

  /// Static function to split full name into first and last name
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// Static function to generate a username from the full name.
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : "";

    String camelCaseUsername =
        "$firstName$lastName"; // Combine first and last name
    String usernameWithPrefix = "maj_$camelCaseUsername"; // Add "cwt_" prefix
    return usernameWithPrefix;
  }

  // Static function to create an empty user model.
  static PatientModel empty() => PatientModel(
        id: '',
        userId: '',
        firstName: '',
        lastName: '',
        username: '',
        phoneNumber: '',
        profilePicture: '',
        gender: '',
        dateOfBirth: '',
        dailyMedicationUsage: '0',
      );

  // Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'PhoneNumber': phoneNumber,
      'ProfilePicture': profilePicture,
      'Gender': gender,
      'DateOfBirth': dateOfBirth,
      'DailyMedicationUsage': dailyMedicationUsage,
    };
  }

  // Factory method to create a UserModel from a Firebase document snapshot.
  factory PatientModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return PatientModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        firstName: data['FirstName'] ?? '',
        lastName: data['LastName'] ?? '',
        username: data['Username'] ?? '',
        phoneNumber: data['PhoneNumber'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        gender: data['Gender'] ?? '',
        dateOfBirth: data['DateOfBirth'] ?? '',
        dailyMedicationUsage: data['DailyMedicationUsage'] ?? '',
      );
    } else {
      return PatientModel.empty();
    }
  }
}
