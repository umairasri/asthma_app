import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing healthcare provider data.
class HealthcareModel {
  final String id;
  final String userId;
  String facilityName;
  final String licenseNumber;
  String facilityContactNumber;
  String facilityAddress;
  String representativeName;
  String representativeEmail;
  final String registrationDocument;
  String profilePicture;
  final bool isApproved;

  /// Constructor for HealthcareModel.
  HealthcareModel({
    required this.id,
    required this.userId,
    required this.facilityName,
    required this.licenseNumber,
    required this.facilityContactNumber,
    required this.facilityAddress,
    required this.representativeName,
    required this.representativeEmail,
    required this.registrationDocument,
    this.profilePicture = '',
    this.isApproved = false,
  });

  /// Static function to create an empty healthcare model.
  static HealthcareModel empty() => HealthcareModel(
        id: '',
        userId: '',
        facilityName: '',
        licenseNumber: '',
        facilityContactNumber: '',
        facilityAddress: '',
        representativeName: '',
        representativeEmail: '',
        registrationDocument: '',
        profilePicture: '',
        isApproved: false,
      );

  /// Convert model to JSON structure for storing data in Firebase.
  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'FacilityName': facilityName,
      'LicenseNumber': licenseNumber,
      'FacilityContactNumber': facilityContactNumber,
      'FacilityAddress': facilityAddress,
      'RepresentativeName': representativeName,
      'RepresentativeEmail': representativeEmail,
      'RegistrationDocument': registrationDocument,
      'ProfilePicture': profilePicture,
      'IsApproved': isApproved,
    };
  }

  /// Factory method to create a HealthcareModel from a Firebase document snapshot.
  factory HealthcareModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return HealthcareModel(
        id: document.id,
        userId: data['UserId'] ?? '',
        facilityName: data['FacilityName'] ?? '',
        licenseNumber: data['LicenseNumber'] ?? '',
        facilityContactNumber: data['FacilityContactNumber'] ?? '',
        facilityAddress: data['FacilityAddress'] ?? '',
        representativeName: data['RepresentativeName'] ?? '',
        representativeEmail: data['RepresentativeEmail'] ?? '',
        registrationDocument: data['RegistrationDocument'] ?? '',
        profilePicture: data['ProfilePicture'] ?? '',
        isApproved: data['IsApproved'] ?? false,
      );
    } else {
      return HealthcareModel.empty();
    }
  }
}
