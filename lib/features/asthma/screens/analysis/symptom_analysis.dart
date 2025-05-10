import 'package:asthma_app/common/widgets/asthma_diary/symptom_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/asthma_diary/symptom_chart_filter.dart';
import 'package:asthma_app/common/widgets/asthma_diary/symptom_type_bar_chart.dart';
import 'package:asthma_app/common/widgets/asthma_diary/symptom_statistics_cards.dart';
import 'package:asthma_app/utils/constants/sizes.dart';

class SymptomAnalysis extends StatefulWidget {
  const SymptomAnalysis({super.key});

  @override
  State<SymptomAnalysis> createState() => _SymptomAnalysisState();
}

class _SymptomAnalysisState extends State<SymptomAnalysis> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),
            const SymptomStatisticsCards(),
            const SizedBox(height: TSizes.spaceBtwSections),
            const SymptomChartFilter(),
            const SizedBox(height: TSizes.spaceBtwSections + 15),
            const SymptomTypeBarChart(),
            const SizedBox(height: TSizes.spaceBtwSections + 15),
            const SymptomPieChart(),
            const SizedBox(height: TSizes.spaceBtwSections + 150),
          ],
        ),
      ),
    );
  }
}
