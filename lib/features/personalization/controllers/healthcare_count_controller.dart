import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';

class HealthcareCountController extends GetxController {
  static HealthcareCountController get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final RxInt unapprovedCount = 0.obs;
  final RxInt approvedCount = 0.obs;
  final RxInt patientCount = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      isLoading.value = true;

      // Fetch unapproved healthcare providers
      final unapprovedSnapshot = await _db
          .collection('Healthcare')
          .where('IsApproved', isEqualTo: false)
          .get();
      unapprovedCount.value = unapprovedSnapshot.docs.length;

      // Fetch approved healthcare providers
      final approvedSnapshot = await _db
          .collection('Healthcare')
          .where('IsApproved', isEqualTo: true)
          .get();
      approvedCount.value = approvedSnapshot.docs.length;

      // Fetch patient count from Users collection
      final patientSnapshot = await _db.collection('Patients').get();
      patientCount.value = patientSnapshot.docs.length;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user counts');
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate growth percentage for healthcare providers
  double getHealthcareGrowth() {
    // This is a placeholder. In a real app, you would compare current count with previous period
    return 12.5; // Example growth percentage
  }

  // Calculate growth percentage for patients
  double getPatientGrowth() {
    // This is a placeholder. In a real app, you would compare current count with previous period
    return 8.3; // Example growth percentage
  }
}
