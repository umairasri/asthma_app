import 'package:asthma_app/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/features/asthma/controllers/symptom_controller.dart';
import 'package:asthma_app/features/asthma/models/symptom_model.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/utils/logger.dart';

class SymptomTrendChart extends StatelessWidget {
  SymptomTrendChart({
    super.key,
    this.disableIcon = false,
  });

  final SymptomController _symptomController = Get.find();
  final SelectedDependentController _selectedDependentController = Get.find();
  final navController = Get.find<NavigationController>();

  List<int> _getSymptomCountsForPast7Days() {
    final now = DateTime.now();
    final String currentUserId =
        _selectedDependentController.getSelectionUserId();

    TLogger.debug(
        'Getting symptom counts for past 7 days for user/dependent: $currentUserId');

    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateString = SymptomModel.formatDate(day);
      return _symptomController.symptoms
          .where((s) => s.userId == currentUserId && s.date == dateString)
          .fold<int>(0, (sum, s) => sum + s.symptom.length);
    });
  }

  List<String> _getDayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(day);
    });
  }

  String _determineSeverityLevel(List<int> counts) {
    if (counts[6] > counts[5] && counts[5] > counts[4]) return "Severe";
    if (counts.toSet().length == 1) return "Well Controlled";
    return "Average";
  }

  final bool disableIcon;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = _getSymptomCountsForPast7Days();
      final labels = _getDayLabels();
      final severity = _determineSeverityLevel(counts);

      return GestureDetector(
        onTap: () {
          navController.selectedIndex.value = 2; // Healthcare tab index
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            // gradient: LinearGradient(
            //   colors: [
            //     TColors.primary
            //         .withOpacity(0.2), // Lighter version of primary color
            //     TColors.secondary.withOpacity(0.3)
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, 3), // Slightly stronger shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Container and Text at the start of the Row
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    severity,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          16, // Slightly larger font size for better visibility
                      color: Colors.black,
                    ),
                  ),

                  // Spacer to push the icon to the far right
                  const Spacer(),

                  // Icon at the far right of the Row
                  Icon(disableIcon ? null : Iconsax.arrow_circle_right),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 120,
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
                        barWidth: 8,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 35,
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: Colors.black
                                        .withOpacity(0.8), // Soft text color
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
