import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:asthma_app/common/widgets/layouts/grid_layout.dart';
import 'package:asthma_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:asthma_app/common/widgets/texts/section_heading.dart';
import 'package:asthma_app/features/asthma/screens/home/widgets/home_appbar.dart';
import 'package:asthma_app/features/asthma/screens/home/widgets/home_categories.dart';
import 'package:asthma_app/features/asthma/screens/home/widgets/promo_slider.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/constants/sizes.dart';

import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// -- Appbar  -- Tutorial [Section # 3, Video # 4]
                  THomeAppBar(),
                  SizedBox(height: TSizes.defaultSpace),

                  /// - Searchbar
                  TSearchContainer(text: 'Search'),
                  SizedBox(height: TSizes.defaultSpace),

                  /// -- Categories
                  Padding(
                    padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        /// -- Heading
                        TSectionHeading(
                          title: 'Popular Categories',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: TSizes.spaceBtwItems),

                        /// Categories
                        THomeCategories(),
                        SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Body
            // -- Carousel Slider Image
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Promo Slider
                  TPromoSlider(
                    banners: [
                      TImages.promoBanner1,
                      TImages.promoBanner2,
                      TImages.promoBanner3,
                      TImages.promoBanner4,
                    ],
                  ),
                  const SizedBox(height: TSizes.defaultSpace),

                  /// -- Heading
                  TSectionHeading(title: 'Popular Products', onPressed: () {}),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// -- Popular Products
                  TGridLayout(
                    itemCount: 5,
                    itemBuilder: (_, index) => TProductCardVertical(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
