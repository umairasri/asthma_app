import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/features/personalization/screens/profile/widgets/add_dependent_form.dart';

class AddDependentScreen extends StatelessWidget {
  const AddDependentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Add Dependent',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: AddDependentForm(),
        ),
      ),
    );
  }
}
