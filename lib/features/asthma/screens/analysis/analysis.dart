import 'package:asthma_app/common/widgets/appbar/tabbar.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/selected_dependent_controller.dart';
import 'package:asthma_app/features/personalization/controllers/patient_controller.dart';
import 'package:asthma_app/features/personalization/controllers/dependent_controller.dart';
import 'package:asthma_app/common/widgets/current_selection_card.dart';
import 'package:asthma_app/common/widgets/shimmer/shimmer.dart';
import 'package:asthma_app/features/asthma/screens/diary/widgets/select_dependent_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:asthma_app/features/asthma/screens/analysis/symptom_analysis.dart';
import 'package:asthma_app/features/asthma/screens/analysis/medication_analysis.dart';

import '../../../../utils/constants/sizes.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final PatientController userController;
  late final DependentController dependentController;
  late final SelectedDependentController selectedDependentController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    userController = Get.find<PatientController>();
    dependentController = Get.put(DependentController());
    selectedDependentController = Get.put(SelectedDependentController());

    _initializeData();
  }

  void _initializeData() {
    // Fetch user data
    userController.fetchUserRecord();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, refresh data
        _initializeData();
      }
    });
  }

  void _showSelectDependentPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => SelectDependentPopup(
          dependentController: dependentController,
          selectedDependentController: selectedDependentController,
          userController: userController,
        ),
      ),
    ).then((_) {
      // Force rebuild when popup is closed
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          /// -- Appbar
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(150),
            child: TPrimaryHeaderContainer(
              height: 120,
              child: TAppBar(
                title: Text('Statistics',
                    style: Theme.of(context).textTheme.headlineMedium!.apply(
                          color: TColors.white,
                        )),
              ),
            ),
          ),
          body: NestedScrollView(
            /// -- Header
            headerSliverBuilder: (_, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  floating: true,
                  backgroundColor: THelperFunctions.isDarkMode(context)
                      ? TColors.black
                      : TColors.white,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                      child: Obx(() {
                        if (userController.profileLoading.value) {
                          return const TShimmerEffect(
                              width: double.infinity, height: 100);
                        }
                        return CurrentSelectionCard(
                          key: ValueKey(
                              selectedDependentController.getSelectionUserId()),
                          onTap: _showSelectDependentPopup,
                          userController: userController,
                          selectedDependentController:
                              selectedDependentController,
                        );
                      }),
                    ),
                  ),

                  /// -- Tabs
                  bottom: TTabBar(
                    tabs: [
                      Tab(child: Text('Symptoms')),
                      Tab(child: Text('Medication')),
                    ],
                  ),
                ),
              ];
            },

            /// -- Body
            body: TabBarView(
              children: [
                const SymptomAnalysis(),
                const MedicationAnalysis(),
              ],
            ),
          ),
        ));
  }
}
