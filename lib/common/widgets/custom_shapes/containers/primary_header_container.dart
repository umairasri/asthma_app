import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/circular_container.dart';

import '../../../../utils/constants/colors.dart';
import '../curved_edges/curved_edges_widget.dart';

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height,
  });

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgeWidget(
      child: SizedBox(
        height: height,
        child: Container(
          color: TColors.primary,
          // height: TDeviceUtils.getScreenHeight() * 0.45,
          padding: const EdgeInsets.only(bottom: 0),

          /// -- If [size.isFinite': is not true.in Stack] error occured -> Read README.md file at [D]
          child: Stack(
            children: [
              /// -- Background Custom Shapes
              Positioned(
                top: -150,
                right: -250,
                child: TCircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: TCircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
