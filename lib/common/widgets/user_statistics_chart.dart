import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';

enum TimePeriod {
  thisMonth('This Month'),
  thisYear('This Year'),
  overall('Overall');

  final String displayName;
  const TimePeriod(this.displayName);
}

class UserStatisticsChart extends StatefulWidget {
  final int healthcareUsers;
  final int patientUsers;
  final double healthcareGrowth;
  final double patientGrowth;
  final String timePeriod;

  const UserStatisticsChart({
    super.key,
    required this.healthcareUsers,
    required this.patientUsers,
    required this.healthcareGrowth,
    required this.patientGrowth,
    required this.timePeriod,
  });

  @override
  State<UserStatisticsChart> createState() => _UserStatisticsChartState();
}

class _UserStatisticsChartState extends State<UserStatisticsChart> {
  TimePeriod _selectedPeriod = TimePeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Title and Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Statistics Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: TColors.grey),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                ),
                child: SizedBox(
                  width: 120,
                  child: DropdownButton<TimePeriod>(
                    isExpanded:
                        true, // Importatant to make it fill the SizedBox nicely
                    value: _selectedPeriod,
                    underline: const SizedBox(),
                    items: TimePeriod.values.map((TimePeriod period) {
                      return DropdownMenuItem<TimePeriod>(
                        value: period,
                        child: Text(
                          period.displayName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (TimePeriod? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriod = newValue;
                        });
                      }
                    },
                  ),
                )),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        // Growth Cards
        Row(
          children: [
            Expanded(
              child: _GrowthCard(
                title: 'Healthcare',
                count: widget.healthcareUsers,
                growth: widget.healthcareGrowth,
                icon: Icons.medical_services,
                color: TColors.primary,
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: _GrowthCard(
                title: 'Patient',
                count: widget.patientUsers,
                growth: widget.patientGrowth,
                icon: Icons.people,
                color: TColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwSections * 2),

        // Pie Chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: TColors.primary,
                  value: widget.healthcareUsers.toDouble(),
                  title:
                      '${((widget.healthcareUsers / (widget.healthcareUsers + widget.patientUsers)) * 100).toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
                PieChartSectionData(
                  color: TColors.secondary,
                  value: widget.patientUsers.toDouble(),
                  title:
                      '${((widget.patientUsers / (widget.healthcareUsers + widget.patientUsers)) * 100).toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections * 2),
        Text(
          'User Distribution (${_selectedPeriod.displayName})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final String title;
  final int count;
  final double growth;
  final IconData icon;
  final Color color;

  const _GrowthCard({
    required this.title,
    required this.count,
    required this.growth,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: TSizes.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.apply(
                  color: color,
                ),
          ),
          const SizedBox(height: TSizes.xs),
          Row(
            children: [
              Icon(
                growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: growth >= 0 ? Colors.green : Colors.red,
                size: 16,
              ),
              Text(
                '${growth.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  color: growth >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
