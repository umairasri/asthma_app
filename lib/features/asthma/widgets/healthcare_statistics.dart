import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asthma_app/features/events/repositories/event_repository.dart';
import 'package:asthma_app/utils/popups/loaders.dart';

class HealthcareStatistics extends StatefulWidget {
  const HealthcareStatistics({super.key});

  @override
  State<HealthcareStatistics> createState() => _HealthcareStatisticsState();
}

class _HealthcareStatisticsState extends State<HealthcareStatistics> {
  final EventRepository _eventRepository = EventRepository();
  final _auth = FirebaseAuth.instance;
  bool isLoading = true;
  String? healthcareId;

  // Statistics data
  int totalEvents = 0;
  int activeEvents = 0;
  int totalParticipants = 0;
  double averageParticipants = 0;
  List<Map<String, dynamic>> eventsByMonth = [];
  List<Map<String, dynamic>> participantDistribution = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        TLoaders.errorSnackBar(title: 'Error', message: 'User not logged in');
        return;
      }

      // Get healthcare ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Healthcare')
          .where('UserId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        TLoaders.errorSnackBar(
            title: 'Error', message: 'Healthcare provider not found');
        return;
      }

      healthcareId = querySnapshot.docs.first.id;

      // Fetch statistics
      final stats =
          await _eventRepository.getHealthcareEventStatistics(healthcareId!);

      setState(() {
        totalEvents = stats['totalEvents'];
        activeEvents = stats['activeEvents'];
        totalParticipants = stats['totalParticipants'];
        averageParticipants = stats['averageParticipants'];
        eventsByMonth = List<Map<String, dynamic>>.from(stats['eventsByMonth']);
        participantDistribution =
            List<Map<String, dynamic>>.from(stats['participantDistribution']);
        isLoading = false;
      });
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to load statistics');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'Healthcare Statistics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Statistics Cards Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Total Events',
                        totalEvents.toString(),
                        Icons.event,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Avg. Participants',
                        averageParticipants.toStringAsFixed(1),
                        Icons.people,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Active Events',
                        activeEvents.toString(),
                        Icons.event_available,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Total Participants',
                        totalParticipants.toString(),
                        Icons.group,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Monthly Events Chart Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Event Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= eventsByMonth.length) {
                                  return const Text('');
                                }
                                final parts = eventsByMonth[value.toInt()]
                                        ['month']
                                    .split(' ');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        parts[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        parts[1],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 22,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        minX: 0,
                        maxX: 4,
                        minY: 0,
                        maxY: eventsByMonth.isEmpty
                            ? 5
                            : eventsByMonth
                                .map((e) => e['count'] as int)
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble(),
                        lineBarsData: [
                          LineChartBarData(
                            spots: eventsByMonth
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                      entry.key.toDouble(),
                                      (entry.value['count'] as int).toDouble(),
                                    ))
                                .toList(),
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.blue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Participation Rate Chart Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Participation Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: participantDistribution
                                  .map((data) => PieChartSectionData(
                                        value:
                                            (data['count'] as int).toDouble(),
                                        title: '${data['percentage']}%',
                                        color:
                                            data['type'] == 'Fully Participated'
                                                ? Colors.green
                                                : Colors.orange,
                                        radius: 50,
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ))
                                  .toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 25,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: participantDistribution
                                .map((data) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: data['type'] ==
                                                      'Fully Participated'
                                                  ? Colors.green
                                                  : Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${data['type']}\n${data['count']} events',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
