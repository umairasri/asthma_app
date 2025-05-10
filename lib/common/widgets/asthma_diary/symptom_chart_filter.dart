import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/asthma/models/symptom_model.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/logger.dart';

enum TrendType { daily, weekly, monthly }

class SymptomChartFilter extends StatefulWidget {
  const SymptomChartFilter({super.key});

  @override
  State<SymptomChartFilter> createState() => _SymptomChartFilterState();
}

class _SymptomChartFilterState extends State<SymptomChartFilter> {
  final SymptomController _symptomController = Get.find();
  final SelectedDependentController _selectedDependentController = Get.find();
  TrendType selectedTrend = TrendType.daily;

  List<int> _getSymptomCounts() {
    final now = DateTime.now();
    final String currentUserId =
        _selectedDependentController.getSelectionUserId();

    TLogger.debug(
        'Getting symptom counts for ${selectedTrend.toString()} for user/dependent: $currentUserId');

    switch (selectedTrend) {
      case TrendType.daily:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final dateString = SymptomModel.formatDate(day);
          return _symptomController.symptoms
              .where((s) => s.userId == currentUserId && s.date == dateString)
              .fold<int>(0, (sum, s) => sum + s.symptom.length);
        });

      case TrendType.weekly:
        return List.generate(7, (i) {
          final startOfWeek = now.subtract(Duration(days: (6 - i) * 7));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          final startDateString = SymptomModel.formatDate(startOfWeek);
          final endDateString = SymptomModel.formatDate(endOfWeek);
          return _symptomController.symptoms
              .where((s) =>
                  s.userId == currentUserId &&
                  s.date.compareTo(startDateString) >= 0 &&
                  s.date.compareTo(endDateString) <= 0)
              .fold<int>(0, (sum, s) => sum + s.symptom.length);
        });

      case TrendType.monthly:
        return List.generate(7, (i) {
          final monthAgo = DateTime(now.year, now.month - (6 - i));
          final firstDayOfMonth = DateTime(monthAgo.year, monthAgo.month, 1);
          final lastDayOfMonth = DateTime(monthAgo.year, monthAgo.month + 1, 0);
          final startDateString = SymptomModel.formatDate(firstDayOfMonth);
          final endDateString = SymptomModel.formatDate(lastDayOfMonth);
          return _symptomController.symptoms
              .where((s) =>
                  s.userId == currentUserId &&
                  s.date.compareTo(startDateString) >= 0 &&
                  s.date.compareTo(endDateString) <= 0)
              .fold<int>(0, (sum, s) => sum + s.symptom.length);
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

  String _determineSeverityLevel(List<int> counts) {
    if (counts.length >= 3 &&
        counts[counts.length - 1] > counts[counts.length - 2] &&
        counts[counts.length - 2] > counts[counts.length - 3]) {
      return "Severe";
    }
    if (counts.toSet().length == 1) return "Well Controlled";
    return "Average";
  }

  bool isWeek() {
    if (selectedTrend == TrendType.weekly) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = _getSymptomCounts();
      final labels = _getLabels();
      final severity = _determineSeverityLevel(counts);

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
                  'Symptom Statistic Trend',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .apply(color: TColors.darkGrey)
                      .copyWith(fontSize: 16),
                ),
                Container(
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
                            fontSize: 14,
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
          SizedBox(height: 10),

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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Severity Indicator
                    Text(
                      severity,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
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
                            color: Colors.blue,
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
                              interval: 4,
                              getTitlesWidget: (value, _) {
                                return Text(value.toInt().toString());
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
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
                        fontSize: 16, fontWeight: FontWeight.w600),
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
