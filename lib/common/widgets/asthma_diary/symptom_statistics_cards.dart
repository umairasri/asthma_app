import 'package:flutter/material.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:intl/intl.dart';

class SymptomStatisticsCards extends StatefulWidget {
  const SymptomStatisticsCards({super.key});

  @override
  State<SymptomStatisticsCards> createState() => _SymptomStatisticsCardsState();
}

class _SymptomStatisticsCardsState extends State<SymptomStatisticsCards> {
  final SymptomController _symptomController = Get.find();
  final SelectedDependentController _selectedDependentController = Get.find();
  String _selectedFilter = 'Today';

  int _getTotalSymptoms() {
    final now = DateTime.now();
    final String currentUserId =
        _selectedDependentController.getSelectionUserId();
    final symptoms = _symptomController.symptoms
        .where((s) => s.userId == currentUserId)
        .toList();

    DateTime startDate;
    switch (_selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return symptoms.where((symptom) {
      final symptomDate = DateFormat('yyyy-MM-dd').parse(symptom.date);
      return symptomDate.isAfter(startDate) ||
          (symptomDate.year == startDate.year &&
              symptomDate.month == startDate.month &&
              symptomDate.day == startDate.day);
    }).fold<int>(0, (sum, s) => sum + s.symptom.length);
  }

  double _getSymptomPercentage() {
    final now = DateTime.now();
    final String currentUserId =
        _selectedDependentController.getSelectionUserId();
    final symptoms = _symptomController.symptoms
        .where((s) => s.userId == currentUserId)
        .toList();

    DateTime startDate;
    int totalDays;
    switch (_selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        totalDays = 1;
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        totalDays = 7;
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        totalDays = DateTime(now.year, now.month + 1, 0).day;
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
        totalDays = 1;
    }

    final daysWithSymptoms = symptoms
        .where((symptom) {
          final symptomDate = DateFormat('yyyy-MM-dd').parse(symptom.date);
          return symptomDate.isAfter(startDate) ||
              (symptomDate.year == startDate.year &&
                  symptomDate.month == startDate.month &&
                  symptomDate.day == startDate.day);
        })
        .map((s) => s.date)
        .toSet()
        .length;

    return (daysWithSymptoms / totalDays) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 120, // Fixed width for the dropdown
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedFilter,
                underline: const SizedBox(),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                items: ['Today', 'This Week', 'This Month'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFilter = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        // Statistics Cards
        Row(
          children: [
            // Total Symptoms Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(TSizes.sm + 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total\n Symptoms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TColors.darkGrey,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(width: TSizes.xs * 2),
                    Text(
                      _getTotalSymptoms().toString(),
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: TColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 45,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems - 3),
            // Symptom Percentage Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Symptom Rate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TColors.darkGrey,
                          ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      '${_getSymptomPercentage().toStringAsFixed(1)}%',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: TColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
