import 'package:asthma_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/features/authentication/controllers/healthcare_signup_controller.dart';
import 'package:asthma_app/features/authentication/screens/signup/widgets/healthcare_signup_form.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:get/get.dart';

class SignupHealthcareScreen extends StatelessWidget {
  const SignupHealthcareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(HealthcareSignupController());

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
                'Healthcare Provider Sign Up',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form
              THealthcareSignupForm(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Link to Patient Signup
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Are you a patient? ',
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
            ],
          ),
        ),
      ),
    );
  }
}
