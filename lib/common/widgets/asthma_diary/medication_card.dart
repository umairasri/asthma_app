import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class TMedicationCard extends StatelessWidget {
  const TMedicationCard({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      showBorder: true,
      borderColor: TColors.darkGrey,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      padding: EdgeInsets.all(TSizes.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: images
            .map((image) => brandTopProductImageWidget(image, context))
            .toList(),
      ),
    );
  }

  Widget brandTopProductImageWidget(String image, context) {
    return TRoundedContainer(
      height: 60,
      padding: EdgeInsets.all(TSizes.spaceBtwItems),
      margin: EdgeInsets.all(TSizes.sm),
      backgroundColor: THelperFunctions.isDarkMode(context)
          ? TColors.darkGrey
          : TColors.secondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(
            fit: BoxFit.contain,
            image: AssetImage(image),
            height: 40,
          ),
          const SizedBox(width: TSizes.sm),
          Text(
            'Usage : 0',
            style: TextStyle(
              color: THelperFunctions.isDarkMode(context)
                  ? Colors.white
                  : Colors.black,
              fontSize: 14, // Adjust font size as needed
            ),
          )
        ],
      ),
    );
  }
}
