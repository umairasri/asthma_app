import 'package:asthma_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/brands/brand_show_case.dart';
import 'package:asthma_app/common/widgets/layouts/grid_layout.dart';
import 'package:asthma_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';

import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TSearchContainer(
                text: 'Search',
                showBorder: true,
                showBackground: false,
                padding: EdgeInsets.zero,
              ),
              SizedBox(height: TSizes.spaceBtwSections + TSizes.spaceBtwItems),

              /// -- Brands
              TBrandShowcase(
                images: [
                  TImages.productImage1,
                  TImages.productImage2,
                  TImages.productImage3
                ],
              ),
              TBrandShowcase(
                images: [
                  TImages.productImage1,
                  TImages.productImage2,
                  TImages.productImage3
                ],
              ),
              SizedBox(height: TSizes.spaceBtwItems),

              /// --- Products
              TSectionHeading(title: 'You might like', onPressed: () {}),
              SizedBox(height: TSizes.spaceBtwItems),

              TGridLayout(
                itemCount: 4,
                itemBuilder: (_, index) => TProductCardVertical(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
