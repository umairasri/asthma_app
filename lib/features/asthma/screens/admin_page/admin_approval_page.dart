import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/features/asthma/screens/admin_page/admin_navigation_menu.dart';

class AdminApprovalPage extends StatelessWidget {
  final HealthcareModel healthcare;

  const AdminApprovalPage({
    super.key,
    required this.healthcare,
  });

  @override
  Widget build(BuildContext context) {
    final healthcareController = Get.put(HealthcareController());
    final Rx<HealthcareModel> reactiveHealthcare = healthcare.obs;

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Healthcare Approval'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: TCircularImage(
                image: reactiveHealthcare.value.profilePicture.isNotEmpty
                    ? reactiveHealthcare.value.profilePicture
                    : TImages.facility,
                width: 100,
                height: 100,
                padding: 5,
                isNetworkImage:
                    reactiveHealthcare.value.profilePicture.isNotEmpty,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Facility Information
            _buildInfoSection(
              context,
              'Facility Information',
              [
                _buildInfoRow(
                    'Facility Name', reactiveHealthcare.value.facilityName),
                _buildInfoRow('Registration Number',
                    reactiveHealthcare.value.licenseNumber),
                _buildInfoRow('Contact Number',
                    reactiveHealthcare.value.facilityContactNumber),
                _buildInfoRow(
                    'Address', reactiveHealthcare.value.facilityAddress),
                const SizedBox(height: TSizes.spaceBtwItems),
                // Registration Document View
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Document',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: TColors.textsecondary,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    InkWell(
                      onTap: () {
                        if (reactiveHealthcare
                            .value.registrationDocument.isNotEmpty) {
                          // Open the document in a web view or download it
                          Get.dialog(
                            Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppBar(
                                    title: Text('Registration Document'),
                                  ),
                                  Expanded(
                                    child: Image.network(
                                      reactiveHealthcare
                                          .value.registrationDocument,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(TSizes.borderRadiusLg),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            Expanded(
                              child: Text(
                                'View Registration Document',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Representative Information
            _buildInfoSection(
              context,
              'Representative Information',
              [
                _buildInfoRow(
                    'Name', reactiveHealthcare.value.representativeName),
                _buildInfoRow(
                    'Email', reactiveHealthcare.value.representativeEmail),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Approval Status and Action Buttons wrapped in Obx
            Obx(() => Column(
                  children: [
                    // Approval Status
                    _buildInfoSection(
                      context,
                      'Approval Status',
                      [
                        _buildInfoRow(
                          'Current Status',
                          reactiveHealthcare.value.isApproved
                              ? 'Approved'
                              : 'Pending Approval',
                          valueColor: reactiveHealthcare.value.isApproved
                              ? TColors.success
                              : TColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections * 2),

                    // Action Buttons
                    reactiveHealthcare.value.isApproved
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(TSizes.md),
                            decoration: BoxDecoration(
                              color: TColors.success.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(TSizes.cardRadiusMd),
                              border: Border.all(color: TColors.success),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: TColors.success),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                Text(
                                  'Healthcare Has Already Been Approved',
                                  style: TextStyle(
                                    color: TColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await healthcareController
                                          .approveHealthcareProvider(
                                              reactiveHealthcare.value.id);
                                      // Create a new instance with updated approval status
                                      reactiveHealthcare.value =
                                          HealthcareModel(
                                        id: reactiveHealthcare.value.id,
                                        userId: reactiveHealthcare.value.userId,
                                        facilityName: reactiveHealthcare
                                            .value.facilityName,
                                        licenseNumber: reactiveHealthcare
                                            .value.licenseNumber,
                                        facilityContactNumber:
                                            reactiveHealthcare
                                                .value.facilityContactNumber,
                                        facilityAddress: reactiveHealthcare
                                            .value.facilityAddress,
                                        representativeName: reactiveHealthcare
                                            .value.representativeName,
                                        representativeEmail: reactiveHealthcare
                                            .value.representativeEmail,
                                        registrationDocument: reactiveHealthcare
                                            .value.registrationDocument,
                                        profilePicture: reactiveHealthcare
                                            .value.profilePicture,
                                        isApproved: true,
                                      );
                                    } catch (e) {
                                      TLoaders.errorSnackBar(
                                        title: 'Error',
                                        message: e.toString(),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.success,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: TSizes.defaultSpace),
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(color: TColors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceBtwItems),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await healthcareController
                                          .rejectHealthcareProvider(
                                              reactiveHealthcare.value.id);
                                      // Create a new instance with updated approval status
                                      reactiveHealthcare.value =
                                          HealthcareModel(
                                        id: reactiveHealthcare.value.id,
                                        userId: reactiveHealthcare.value.userId,
                                        facilityName: reactiveHealthcare
                                            .value.facilityName,
                                        licenseNumber: reactiveHealthcare
                                            .value.licenseNumber,
                                        facilityContactNumber:
                                            reactiveHealthcare
                                                .value.facilityContactNumber,
                                        facilityAddress: reactiveHealthcare
                                            .value.facilityAddress,
                                        representativeName: reactiveHealthcare
                                            .value.representativeName,
                                        representativeEmail: reactiveHealthcare
                                            .value.representativeEmail,
                                        registrationDocument: reactiveHealthcare
                                            .value.registrationDocument,
                                        profilePicture: reactiveHealthcare
                                            .value.profilePicture,
                                        isApproved: false,
                                      );
                                    } catch (e) {
                                      TLoaders.errorSnackBar(
                                        title: 'Error',
                                        message: e.toString(),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.error,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: TSizes.defaultSpace),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: TColors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor = TColors.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TColors.textsecondary,
              ),
            ),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
              maxLines: 10,
            ),
          ),
        ],
      ),
    );
  }
}
