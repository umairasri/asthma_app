import 'package:asthma_app/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/common/widgets/login_signup/form_field.dart';
import 'package:asthma_app/features/authentication/controllers/healthcare_signup_controller.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/constants/text_strings.dart';
import 'package:asthma_app/utils/validators/validation.dart';
import 'package:image_picker/image_picker.dart';

class THealthcareSignupForm extends StatefulWidget {
  const THealthcareSignupForm({super.key});

  @override
  State<THealthcareSignupForm> createState() => _THealthcareSignupFormState();
}

class _THealthcareSignupFormState extends State<THealthcareSignupForm> {
  final _controller = Get.put(HealthcareSignupController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Facility Information Section
          Text(
            'Facility Information',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                /// Facility Name
                TFormField(
                  controller: _controller.facilityNameController,
                  labelText: 'Facility Name',
                  prefixIcon: Icons.business_outlined,
                  validator: (value) =>
                      TValidator.validateEmptyText('Facility Name', value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// License Number
                TFormField(
                  controller: _controller.licenseNumberController,
                  labelText: 'Registration Number',
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) =>
                      TValidator.validateEmptyText('License Number', value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Facility Email
                TFormField(
                  controller: _controller.facilityEmailController,
                  labelText: 'Facility Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => TValidator.validateEmail(value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Facility Contact Number
                TFormField(
                  controller: _controller.facilityContactNumberController,
                  labelText: 'Facility Contact Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => TValidator.validateEmptyText(
                      'Facility Contact Number', value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Facility Address
                TextFormField(
                  controller: _controller.facilityAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Facility Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      TValidator.validateEmptyText('Facility Address', value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Registration Document Upload
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration Document',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        InkWell(
                          onTap: () => _controller.pickRegistrationDocument(),
                          child: Container(
                            padding: const EdgeInsets.all(TSizes.defaultSpace),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.circular(TSizes.borderRadiusLg),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: TSizes.spaceBtwItems),
                                Expanded(
                                  child: Text(
                                    _controller.registrationDocumentName.value
                                            .isEmpty
                                        ? 'Upload Registration Document (PDF/Image)'
                                        : _controller
                                            .registrationDocumentName.value,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_controller
                            .registrationDocumentError.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _controller.registrationDocumentError.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Representative Information Section
          Text(
            'Staff Information',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                /// Representative Name
                TFormField(
                  controller: _controller.representativeNameController,
                  labelText: 'Staff Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      TValidator.validateEmptyText('Staff Name', value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Representative Email
                TFormField(
                  controller: _controller.representativeEmailController,
                  labelText: 'Staff Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => TValidator.validateEmail(value),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),

                /// Registration Document Upload
              ],
            ),
          ),

          // Account Information Section
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                /// Password
                Obx(() => TFormField(
                      controller: _controller.passwordController,
                      labelText: TTexts.password,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _controller.hidePassword.value,
                      suffixIcon: IconButton(
                        icon: Icon(_controller.hidePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => _controller.togglePasswordVisibility(),
                      ),
                      validator: (value) => TValidator.validatePassword(value),
                    )),
              ],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Terms&Condition Checkbox
          TTermsAndConditionCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _controller.registerHealthcareProvider(),
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
