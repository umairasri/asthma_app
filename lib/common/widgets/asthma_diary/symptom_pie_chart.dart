import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:intl/intl.dart';

class SymptomPieChart extends StatefulWidget {
  const SymptomPieChart({Key? key}) : super(key: key);

  @override
  State<SymptomPieChart> createState() => _SymptomPieChartState();
}

class _SymptomPieChartState extends State<SymptomPieChart> {
  final SymptomController _symptomController = Get.find<SymptomController>();
  final SelectedDependentController _selectedDependentController =
      Get.find<SelectedDependentController>();

  String _selectedFilter = 'Today';
  Map<String, int> _symptomCounts = {};
  List<MapEntry<String, int>> _topSymptoms = [];

  // Color mapping for symptoms with softer colors
  final Map<String, Color> _symptomColors = {
    'Cough': const Color(0xFF64B5F6), // Light Blue
    'Chest Compression': const Color(0xFFEF5350), // Light Red
    'Wheezing': const Color(0xFF81C784), // Light Green
    'Stress': const Color(0xFFBA68C8), // Light Purple
    'Fever': const Color(0xFFFFB74D), // Light Orange
    'Dizziness': const Color(0xFF4DD0E1), // Light Teal
    'Fast Heartbeat': const Color(0xFFF06292), // Light Pink
    'Shortness of breath': const Color(0xFF7986CB), // Light Indigo
    'Rapid Breathing': const Color(0xFFFFD54F), // Light Amber
    'Headache': const Color(0xFF4FC3F7), // Light Cyan
  };

  Color _getSymptomColor(String symptomType) {
    return _symptomColors[symptomType] ?? Colors.grey.shade300;
  }

  @override
  void initState() {
    super.initState();
    _loadSymptomData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSymptomData();
  }

  Future<void> _loadSymptomData() async {
    setState(() {
      _symptomCounts = {};
    });

    final userId = _selectedDependentController.getSelectionUserId();
    final symptoms =
        _symptomController.symptoms.where((s) => s.userId == userId).toList();

    final now = DateTime.now();
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

    // Count symptoms based on filter
    for (var symptom in symptoms) {
      final dateParts = symptom.date.split('-');
      if (dateParts.length == 3) {
        final symptomDate = DateTime(int.parse(dateParts[0]),
            int.parse(dateParts[1]), int.parse(dateParts[2]));

        if (symptomDate.isAfter(startDate) ||
            (symptomDate.year == startDate.year &&
                symptomDate.month == startDate.month &&
                symptomDate.day == startDate.day)) {
          for (var sym in symptom.symptom) {
            final name = sym['name'] as String?;
            if (name != null) {
              _symptomCounts[name] = (_symptomCounts[name] ?? 0) + 1;
            }
          }
        }
      }
    }

    // Get top 5 symptoms
    _topSymptoms = _symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (_topSymptoms.length > 5) {
      _topSymptoms = _topSymptoms.sublist(0, 5);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// -- Chart Title with Filter
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Recorded Symptoms',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .apply(color: TColors.darkGrey)
                    .copyWith(fontSize: 16),
              ),
              Container(
                width: 120,
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
                  items:
                      ['Today', 'This Week', 'This Month'].map((String value) {
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
                      _loadSymptomData();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        /// -- Body Chart
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 400,
                child: _topSymptoms.isEmpty
                    ? const Center(
                        child: Text(
                          'No Symptoms Recorded',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Legend at the top
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _topSymptoms.map((symptom) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSymptomColor(symptom.key)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getSymptomColor(symptom.key)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getSymptomColor(symptom.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      symptom.key,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${symptom.value})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          // Pie Chart
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections:
                                    _topSymptoms.asMap().entries.map((entry) {
                                  final symptom = entry.value;
                                  return PieChartSectionData(
                                    color: _getSymptomColor(symptom.key),
                                    value: symptom.value.toDouble(),
                                    title: '${symptom.value}',
                                    radius: 90,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 3,
                                centerSpaceRadius: 35,
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
