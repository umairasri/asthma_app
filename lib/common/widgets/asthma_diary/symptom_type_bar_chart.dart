import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomTypeBarChart extends StatefulWidget {
  const SymptomTypeBarChart({Key? key}) : super(key: key);

  @override
  State<SymptomTypeBarChart> createState() => _SymptomTypeBarChartState();
}

class _SymptomTypeBarChartState extends State<SymptomTypeBarChart> {
  final SymptomController _symptomController = Get.find<SymptomController>();
  final SelectedDependentController _selectedDependentController =
      Get.find<SelectedDependentController>();

  String _selectedFilter = 'Today'; // Default filter
  Map<String, int> _symptomCounts = {};
  List<String> _symptomTypes = [];

  // Add color mapping for symptoms
  final Map<String, Color> _symptomColors = {
    'Cough': Colors.blue,
    'Chest Compression': Colors.red,
    'Wheezing': Colors.green,
    'Stress': Colors.purple,
    'Fever': Colors.orange,
    'Dizziness': Colors.teal,
    'Fast Heartbeat': Colors.pink,
    'Shortness of breath': Colors.indigo,
    'Rapid Breathing': Colors.amber,
    'Headache': Colors.cyan,
  };

  Color _getSymptomColor(String symptomType) {
    return _symptomColors[symptomType] ??
        Colors.grey; // Default to grey if no color is mapped
  }

  @override
  void initState() {
    super.initState();
    _loadSymptomData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when dependent changes
    _loadSymptomData();
  }

  Future<void> _loadSymptomData() async {
    setState(() {
      _symptomCounts = {};
      _symptomTypes = [];
    });

    final userId = _selectedDependentController.getSelectionUserId();
    final symptoms =
        _symptomController.symptoms.where((s) => s.userId == userId).toList();

    // Define all possible symptom types
    final allSymptomTypes = [
      'Cough',
      'Chest Compression',
      'Wheezing',
      'Stress',
      'Fever',
      'Dizziness',
      'Fast Heartbeat',
      'Shortness of breath',
      'Rapid Breathing',
      'Headache',
    ];

    // Initialize counts for all symptom types
    for (var type in allSymptomTypes) {
      _symptomCounts[type] = 0;
    }

    final now = DateTime.now();
    DateTime startDate;

    // Set start date based on filter
    switch (_selectedFilter) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        // Find the start of the current week (Monday)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    TLogger.debug('Loading symptom data for $userId from $startDate to $now');

    // Count symptoms based on filter
    for (var symptom in symptoms) {
      // Parse the date string to DateTime
      final dateParts = symptom.date.split('-');
      if (dateParts.length == 3) {
        final symptomDate = DateTime(int.parse(dateParts[0]),
            int.parse(dateParts[1]), int.parse(dateParts[2]));

        if (symptomDate.isAfter(startDate) ||
            (symptomDate.year == startDate.year &&
                symptomDate.month == startDate.month &&
                symptomDate.day == startDate.day)) {
          // Count each symptom type
          for (var type in allSymptomTypes) {
            for (var sym in symptom.symptom) {
              if (sym['name']?.toLowerCase().contains(type.toLowerCase()) ??
                  false) {
                _symptomCounts[type] = (_symptomCounts[type] ?? 0) + 1;
              }
            }
          }
        }
      }
    }

    // Get non-zero symptom types for display
    _symptomTypes =
        allSymptomTypes.where((type) => _symptomCounts[type]! > 0).toList();

    // If no symptoms found, add a placeholder
    if (_symptomTypes.isEmpty) {
      _symptomTypes = ['No Symptoms'];
      _symptomCounts['No Symptoms'] = 0;
    }

    setState(() {});
    TLogger.debug('Loaded ${_symptomTypes.length} symptom types with data');
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
                'Symptom Types Trend',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 450,
                child: _symptomTypes.isEmpty ||
                        (_symptomTypes.length == 1 &&
                            _symptomTypes[0] == 'No Symptoms')
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
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: _symptomTypes.length * 120.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 26.0),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceBetween,
                                maxY: _getMaxValue() * 1.2,
                                minY: 0,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipRoundedRadius: 8,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${_symptomTypes[group.x.toInt()]}\n${rod.toY.toInt()}',
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 60,
                                      getTitlesWidget: (value, meta) {
                                        if (value < 0 ||
                                            value >= _symptomTypes.length) {
                                          return const SizedBox();
                                        }
                                        return SizedBox(
                                          width: 100,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              _symptomTypes[value.toInt()],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 1.0,
                                      getTitlesWidget: (value, meta) {
                                        if (value == value.roundToDouble()) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1.0,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                barGroups:
                                    _symptomTypes.asMap().entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: _symptomCounts[entry.value]
                                                ?.toDouble() ??
                                            0,
                                        color: _getSymptomColor(entry.value),
                                        width: 30,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMaxValue() {
    if (_symptomCounts.isEmpty) return 10;
    return _symptomCounts.values.reduce((a, b) => a > b ? a : b).toDouble();
  }
}
