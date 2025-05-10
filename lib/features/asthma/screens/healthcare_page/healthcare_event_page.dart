import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../events/widgets/event_form.dart';
import '../../../events/widgets/healthcare_events_list.dart';
import '../../../events/controllers/event_controller.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/utils/logger.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';

class HealthcareEventPage extends StatefulWidget {
  const HealthcareEventPage({super.key});

  @override
  State<HealthcareEventPage> createState() => _HealthcareEventPageState();
}

class _HealthcareEventPageState extends State<HealthcareEventPage> {
  final EventController eventController = Get.put(EventController());
  final TextEditingController _searchController = TextEditingController();
  String? healthcareId;
  bool isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Upcoming', 'Past'];

  @override
  void initState() {
    super.initState();
    _initializeHealthcareId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  Future<void> _initializeHealthcareId() async {
    try {
      final id = await _getHealthcareId();
      setState(() {
        healthcareId = id;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      TLogger.error('Failed to initialize healthcare ID: $e');
    }
  }

  Future<String?> _getHealthcareId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        TLogger.error('User not logged in');
        TLoaders.errorSnackBar(title: 'Error', message: 'User not logged in');
        return null;
      }

      TLogger.info('Getting healthcare ID for user: ${user.uid}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Healthcare')
          .where('UserId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        TLogger.error('No healthcare document found for user: ${user.uid}');
        TLoaders.errorSnackBar(
            title: 'Error',
            message:
                'Healthcare provider not found. Please ensure you are registered as a healthcare provider.');
        return null;
      }

      final id = querySnapshot.docs.first.id;
      TLogger.info('Found healthcare ID: $id');
      return id;
    } catch (e) {
      TLogger.error('Failed to get healthcare ID: $e');
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to get healthcare ID. Please try again later.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (healthcareId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Healthcare Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: const Center(
          child: Text('Unable to load healthcare provider information'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Healthcare Events',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TRoundedContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  backgroundColor: TColors.light,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: const TextStyle(
                        color: TColors.darkGrey,
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.search,
                          color: TColors.darkGrey,
                          size: 20,
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: TColors.darkGrey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
                        borderSide: const BorderSide(color: TColors.darkGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
                        borderSide: const BorderSide(color: TColors.darkGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(TSizes.cardRadiusLg),
                        borderSide: const BorderSide(color: TColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TSizes.md,
                        vertical: TSizes.sm,
                      ),
                      filled: true,
                      fillColor: TColors.light,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.dark,
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                // Filter Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.filter_list, color: TColors.darkGrey),
                    const SizedBox(width: TSizes.spaceBtwItems),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Filter Events',
                          labelStyle: const TextStyle(color: TColors.darkGrey),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusLg),
                            borderSide:
                                const BorderSide(color: TColors.darkGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusLg),
                            borderSide:
                                const BorderSide(color: TColors.darkGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusLg),
                            borderSide:
                                const BorderSide(color: TColors.primary),
                          ),
                        ),
                        items: _filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Events List
          Expanded(
            child: HealthcareEventsList(
              healthcareId: healthcareId!,
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => EventForm(healthcareId: healthcareId!));
          },
          backgroundColor: TColors.primary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
