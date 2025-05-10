import 'package:asthma_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TCalendarWidget extends StatelessWidget {
  const TCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final List<DateTime> dateList =
        List.generate(5, (i) => today.add(Duration(days: i - 2)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: dateList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final date = dateList[index];
          final dayNumber = DateFormat('d').format(date);
          final dayName = DateFormat('E').format(date);
          final isToday = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(today);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                // TODO: Add your tap logic here
              },
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  color: isToday ? Colors.white : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isToday ? TColors.primary : Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNumber,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isToday ? TColors.primary : Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
