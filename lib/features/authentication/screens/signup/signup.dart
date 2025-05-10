import 'package:asthma_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/login_signup/form_divider.dart';
import 'package:asthma_app/common/widgets/login_signup/social_buttons.dart';
import 'package:asthma_app/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/authentication/screens/signup/signup_healthcare.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                TTexts.signUpTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form
              TSignupForm(),
              const SizedBox(height: TSizes.spaceBtwSections - 5),

              /// Divider
              TFormDivider(dividerText: TTexts.orSignUpWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Social Buttons
              TSocialButtons(),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Healthcare Provider Signup Link
              Center(
                child: TextButton(
                  onPressed: () => Get.to(() => const SignupHealthcareScreen()),
                  child: RichText(
                    text: TextSpan(
                      text: 'Are you a healthcare provider? ',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .apply(color: TColors.primary),
                      children: [
                        TextSpan(
                          text: ' Sign up here',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: TColors.primary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
