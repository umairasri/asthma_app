import 'package:flutter/material.dart';
import 'package:asthma_app/common/styles/spacing_styles.dart';
import 'package:asthma_app/common/widgets/login_signup/form_divider.dart';
import 'package:asthma_app/common/widgets/login_signup/social_buttons.dart';
import 'package:asthma_app/features/authentication/screens/login/widgets/login_form.dart';
import 'package:asthma_app/features/authentication/screens/login/widgets/login_header.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/text_strings.dart';
import 'package:get/get_utils/get_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              TLoginHeader(),

              /// Form
              TLoginForm(),

              /// Divider
              TFormDivider(dividerText: TTexts.orSignInWith.capitalize!),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Footer
              TSocialButtons()
            ],
          ),
        ),
      ),
    );
  }
}
