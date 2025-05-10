import 'package:get/get.dart';
import 'package:asthma_app/data/repositories/healthcare/healthcare_repository.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_home_page.dart';
import 'package:asthma_app/utils/popups/loaders.dart';

class WaitingApprovalController extends GetxController {
  static WaitingApprovalController get instance => Get.find();

  final healthcareRepository = Get.put(HealthcareRepository());
  final isLoading = false.obs;

  /// Check if the healthcare provider has been approved
  Future<void> checkApprovalStatus() async {
    try {
      isLoading.value = true;

      // Fetch the healthcare record
      final healthcareData =
          await healthcareRepository.fetchHealthcareDetails();

      // If approved, navigate to healthcare home page
      if (healthcareData.isApproved) {
        Get.offAll(() => const HealthcareHomePage());
      } else {
        // Show message that account is still pending
        TLoaders.warningSnackBar(
          title: 'Still Pending',
          message:
              'Your account is still pending approval. Please check back later.',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to check approval status: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
