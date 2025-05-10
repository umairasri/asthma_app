import 'package:asthma_app/common/widgets/custom_shapes/containers/search_container_func.dart';
import 'package:asthma_app/features/asthma/controllers/medication_controller.dart';
import 'package:asthma_app/features/asthma/models/medication_model.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/navigation_menu.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';

class TMedicationTab extends StatefulWidget {
  const TMedicationTab({super.key});

  @override
  State<TMedicationTab> createState() => _TMedicationTabState();
}

class _TMedicationTabState extends State<TMedicationTab> {
  final List<String> _medications = [
    'Blue Inhaler Salbutamol',
    'Gas Nebulizer',
    'Ventolin Syrup',
  ];

  final Map<String, String> _medicationIcons = {
    'Blue Inhaler Salbutamol': TImages.inhaler,
    'Gas Nebulizer': TImages.nebulizer,
    'Ventolin Syrup': TImages.syrup,
  };

  final Set<String> _selectedMedications = {};
  TimeOfDay _selectedTime =
      TimeOfDay.now(); // Time of day for medications logging

  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredMedications =
      []; // List of medications filtered based on search

  @override
  void initState() {
    super.initState();
    _filteredMedications = _medications; // Initialize with all medications
    _searchController
        .addListener(_filterMedications); // Add listener for search input
  }

  void _toggleMedication(String medication) {
    setState(() {
      _selectedMedications.contains(medication)
          ? _selectedMedications.remove(medication)
          : _selectedMedications.add(medication);
    });
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null && time != _selectedTime) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  // Function to filter medications based on the search query
  void _filterMedications() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMedications = _medications
          .where((medication) => medication.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _submitMedications() async {
    try {
      if (_selectedMedications.isEmpty) return;

      final selectedDependentController =
          Get.find<SelectedDependentController>();
      final userId = selectedDependentController.getSelectionUserId();

      if (userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      final now = DateTime.now();

      // Build list of medications with name and icon
      final List<Map<String, String>> medicationData =
          _selectedMedications.map((medication) {
        return {
          'name': medication,
          'icon': _medicationIcons[medication] ?? TImages.inhaler,
        };
      }).toList();

      // Create MedicationModel object with date and timeInMinutes
      final medicationModel = MedicationModel(
        id: '',
        medication: medicationData,
        userId: userId,
        date: MedicationModel.formatDate(now),
        time: MedicationModel.formatTime(_selectedTime),
      );

      // Save the medication
      await MedicationController.instance.addMedication(medicationModel);

      TLoaders.successSnackBar(
          title: 'Saved!', message: 'Medications recorded.');

      setState(() {
        _selectedMedications.clear();
        _selectedTime = TimeOfDay.now();
      });

      // Navigate to home page with bottom navigation
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to save: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TSearchContainerFunc(
                text: 'Search medications...',
                controller: _searchController, // Pass the controller here
                showBorder: false,
                showBackground: false,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Medication List
              ..._filteredMedications.map((medication) {
                final isSelected = _selectedMedications.contains(medication);
                return Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        _medicationIcons[medication] ?? TImages.inhaler,
                        height: 24,
                        width: 24,
                      ),
                      title: Text(medication),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      onTap: () => _toggleMedication(medication),
                    ),

                    /// Divider
                    Divider(
                      color: THelperFunctions.isDarkMode(context)
                          ? TColors.darkGrey
                          : TColors.grey,
                      thickness: 0.5,
                      indent: 60,
                      endIndent: 5,
                    ),
                  ],
                );
              }),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Time Selection
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      'Time: ${_selectedTime.format(context)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitMedications,
                  child: const Text('Record Medications'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
