import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/icons/t_circular_icon.dart';
import 'package:asthma_app/common/widgets/layouts/grid_layout.dart';
import 'package:asthma_app/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:asthma_app/features/asthma/screens/home/home.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title:
            Text('Wishlist', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TCircularIcon(
            icon: Iconsax.add,
            onPressed: () => Get.to(HomeScreen()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              TGridLayout(
                  itemCount: 7,
                  itemBuilder: (_, index) => TProductCardVertical())
            ],
          ),
        ),
      ),
    );
  }
}
