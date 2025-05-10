import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';

class TSymptomTrackerCard extends StatelessWidget {
  const TSymptomTrackerCard({
    super.key,
    required this.time,
    required this.symptoms,
    required this.iconPath, // Changed to take iconPath instead of widget
  });

  final String time;
  final List<String> symptoms; // A list of symptom names
  final String iconPath; // Path to the icon (string)

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      showBorder: true,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: const EdgeInsets.all(TSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row: Icon + Title + Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(TSizes.sm),
                decoration: BoxDecoration(
                  color: TColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ), // Display icon as image asset
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Symptoms",
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(time, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Symptoms as chips or tags
          Wrap(
            spacing: TSizes.sm,
            runSpacing: TSizes.sm,
            children: symptoms
                .map((symptom) => Chip(
                      label: Text(
                        symptom,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .apply(fontSizeDelta: -1),
                      ),
                      backgroundColor: TColors.lightGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
