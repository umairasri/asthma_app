import 'package:asthma_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/features/personalization/models/dependent_model.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:asthma_app/utils/popups/loaders.dart';

class EditDependentScreen extends StatefulWidget {
  final dynamic dependent;

  const EditDependentScreen({super.key, required this.dependent});

  @override
  State<EditDependentScreen> createState() => _EditDependentScreenState();
}

class _EditDependentScreenState extends State<EditDependentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dailyMedicationUsageController;
  File? _image;
  final controller = Get.put(DependentController());
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with safe default values if null
    _nameController = TextEditingController(text: widget.dependent.name ?? '');
    _dailyMedicationUsageController = TextEditingController(
        text: widget.dependent.dailyMedicationUsage ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dailyMedicationUsageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        TLogger.debug('Image picked: ${pickedFile.path}');
      }
    } catch (e) {
      TLogger.error('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Edit Dependent',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: true,
        iconColor: TColors.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (widget.dependent.profilePicture != null &&
                                  widget.dependent.profilePicture.isNotEmpty
                              ? NetworkImage(widget.dependent.profilePicture)
                              : null) as ImageProvider?,
                      child: _image == null &&
                              (widget.dependent.profilePicture == null ||
                                  widget.dependent.profilePicture.isEmpty)
                          ? const Icon(Iconsax.user, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Iconsax.camera, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (value) =>
                      TValidator.validateEmptyText('Name', value),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Daily Medication Usage
                TextFormField(
                  controller: _dailyMedicationUsageController,
                  decoration: const InputDecoration(
                    labelText: 'Daily Medication Usage',
                    prefixIcon: Icon(Iconsax.clock),
                    hintText: 'e.g., 2 times per day',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => TValidator.validateEmptyText(
                      'Daily Medication Usage', value),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Read-only fields
                _buildReadOnlyField(
                  label: 'Gender',
                  value: widget.dependent.gender ?? 'Not specified',
                  icon: Iconsax.user,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                _buildReadOnlyField(
                  label: 'Date of Birth',
                  value: widget.dependent.dateOfBirth ?? 'Not specified',
                  icon: Iconsax.calendar,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                _buildReadOnlyField(
                  label: 'Relation',
                  value: widget.dependent.relation ?? 'Not specified',
                  icon: Iconsax.user_add,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateDependent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Dependent'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateDependent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? profilePictureUrl = widget.dependent.profilePicture;

      // Upload new image if selected
      if (_image != null) {
        TLogger.debug('Uploading new profile picture');
        profilePictureUrl = await controller.uploadDependentImage(
            widget.dependent.id ?? '', XFile(_image!.path));
        TLogger.debug('Profile picture uploaded: $profilePictureUrl');
      }

      final updatedDependent = DependentModel(
        id: widget.dependent.id ?? '',
        name: _nameController.text.trim(),
        gender: widget.dependent.gender ?? 'Male',
        dateOfBirth: widget.dependent.dateOfBirth ?? '',
        relation: widget.dependent.relation ?? 'Child',
        profilePicture: profilePictureUrl ?? '',
        userId: widget.dependent.userId ?? '',
        dailyMedicationUsage: _dailyMedicationUsageController.text.trim(),
        createdAt: widget.dependent.createdAt ?? Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await controller.updateDependent(updatedDependent);

      Get.back();
      TLoaders.successSnackBar(
          title: 'Success', message: 'Dependent updated successfully');
    } catch (e) {
      TLogger.error('Error updating dependent: $e');
      Get.snackbar(
        'Error',
        'Failed to update dependent. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
