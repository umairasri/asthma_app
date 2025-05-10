import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/features/asthma/controllers/medication_controller.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:intl/intl.dart';

enum TrendType { daily, weekly, monthly }

class MedicationChartFilter extends StatefulWidget {
  const MedicationChartFilter({super.key});

  @override
  State<MedicationChartFilter> createState() => _MedicationChartFilterState();
}

class _MedicationChartFilterState extends State<MedicationChartFilter> {
  final MedicationController _medicationController = Get.find();
  final SelectedDependentController _selectedDependentController = Get.find();
  TrendType selectedTrend = TrendType.daily;

  List<int> _getMedicationCounts() {
    final now = DateTime.now();
    final String currentUserId =
        _selectedDependentController.getSelectionUserId();

    TLogger.debug(
        'Getting medication counts for ${selectedTrend.toString()} for user/dependent: $currentUserId');

    switch (selectedTrend) {
      case TrendType.daily:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final dateString = DateFormat('yyyy-MM-dd').format(day);
          return _medicationController.medications
              .where((m) => m.userId == currentUserId && m.date == dateString)
              .fold<int>(0, (sum, m) => sum + m.medication.length);
        });

      case TrendType.weekly:
        return List.generate(7, (i) {
          final startOfWeek = now.subtract(Duration(days: (6 - i) * 7));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          final startDateString = DateFormat('yyyy-MM-dd').format(startOfWeek);
          final endDateString = DateFormat('yyyy-MM-dd').format(endOfWeek);
          return _medicationController.medications
              .where((m) =>
                  m.userId == currentUserId &&
                  m.date.compareTo(startDateString) >= 0 &&
                  m.date.compareTo(endDateString) <= 0)
              .fold<int>(0, (sum, m) => sum + m.medication.length);
        });

      case TrendType.monthly:
        return List.generate(7, (i) {
          final monthAgo = DateTime(now.year, now.month - (6 - i));
          final firstDayOfMonth = DateTime(monthAgo.year, monthAgo.month, 1);
          final lastDayOfMonth = DateTime(monthAgo.year, monthAgo.month + 1, 0);
          final startDateString =
              DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
          final endDateString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
          return _medicationController.medications
              .where((m) =>
                  m.userId == currentUserId &&
                  m.date.compareTo(startDateString) >= 0 &&
                  m.date.compareTo(endDateString) <= 0)
              .fold<int>(0, (sum, m) => sum + m.medication.length);
        });
    }
  }

  List<String> _getLabels() {
    final now = DateTime.now();
    switch (selectedTrend) {
      case TrendType.daily:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          return DateFormat('E').format(day);
        });

      case TrendType.weekly:
        return List.generate(7, (i) {
          final weekStart =
              now.subtract(Duration(days: now.weekday - 1 + 7 * (6 - i)));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return '${DateFormat('d MMM').format(weekStart)}\n${DateFormat('d MMM').format(weekEnd)}';
        });

      case TrendType.monthly:
        return List.generate(7, (i) {
          final monthDate = DateTime(now.year, now.month - (6 - i));
          return DateFormat('MMM').format(monthDate);
        });
    }
  }

  String _determineAdherenceLevel(List<int> counts) {
    if (counts.isEmpty) return "No Data";

    final average = counts.reduce((a, b) => a + b) / counts.length;
    if (average >= 4) return "Excellent";
    if (average >= 3) return "Good";
    if (average >= 2) return "Fair";
    return "Poor";
  }

  bool isWeek() {
    return selectedTrend == TrendType.weekly;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = _getMedicationCounts();
      final labels = _getLabels();
      final adherence = _determineAdherenceLevel(counts);

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
                  'Medication Usage Trend',
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
                  child: DropdownButton<TrendType>(
                    value: selectedTrend,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: TrendType.values.map((TrendType type) {
                      return DropdownMenuItem<TrendType>(
                        value: type,
                        child: Text(
                          type == TrendType.daily
                              ? 'Daily'
                              : type == TrendType.weekly
                                  ? 'Weekly'
                                  : 'Monthly',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (TrendType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedTrend = newValue;
                        });
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
                Row(
                  children: [
                    /// Chart Stroke Color
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Adherence Indicator
                    Text(
                      adherence,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 23),
                SizedBox(
                  height: 235,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              counts.length,
                              (i) => FlSpot(i.toDouble(), counts[i].toDouble()),
                            ),
                            isCurved: false,
                            color: TColors.primary,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                          )
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 55,
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index >= 0 && index < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      labels[index],
                                      textAlign: TextAlign.center,
                                      style: isWeek()
                                          ? const TextStyle(fontSize: 10)
                                          : const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, _) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    selectedTrend == TrendType.daily
                        ? 'Days Trend'
                        : selectedTrend == TrendType.weekly
                            ? 'Weekly Trend'
                            : 'Monthly Trend',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
