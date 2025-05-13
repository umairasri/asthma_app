import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/personalization/controllers/healthcare_controller.dart';
import 'package:asthma_app/features/personalization/models/healthcare_model.dart';
import 'package:asthma_app/utils/constants/colors.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/common/widgets/appbar/appbar.dart';
import 'package:asthma_app/common/widgets/images/t_circular_image.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/features/asthma/screens/admin_page/admin_approval_page.dart';
import 'package:asthma_app/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:flutter/rendering.dart';

class AdminHealthcarePage extends StatefulWidget {
  const AdminHealthcarePage({super.key});

  @override
  State<AdminHealthcarePage> createState() => _AdminHealthcarePageState();
}

class _AdminHealthcarePageState extends State<AdminHealthcarePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Approved',
    'Pending',
    'Rejected'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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

  List<HealthcareModel> _filterHealthcareProviders(
      List<HealthcareModel> providers) {
    return providers.where((provider) {
      // First check if the provider matches the search term
      final matchesSearch = _searchQuery.isEmpty ||
          provider.facilityName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Then check if the provider matches the selected status
      final matchesStatus = _selectedFilter == 'All' ||
          (_selectedFilter == 'Approved' && provider.status == 'Approved') ||
          (_selectedFilter == 'Pending' && provider.status == 'Pending') ||
          (_selectedFilter == 'Rejected' && provider.status == 'Rejected');

      // Return true only if both conditions are met
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final healthcareController = Get.put(HealthcareController());

    return Scaffold(
      appBar: TAppBar(
        title: Text(
          'Healthcares',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        showBackArrow: false,
      ),
      body: Obx(
        () {
          if (healthcareController.profileLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<List<HealthcareModel>>(
            future: healthcareController.getAllHealthcareProviders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final healthcareProviders = snapshot.data ?? [];
              final filteredProviders =
                  _filterHealthcareProviders(healthcareProviders);

              return Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
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
                          backgroundColor: TColors.primary.withOpacity(0.3),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _handleSearch,
                            decoration: InputDecoration(
                              hintText: 'Search healthcare...',
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
                            const Icon(Icons.filter_list,
                                color: TColors.darkGrey),
                            const SizedBox(width: TSizes.spaceBtwItems),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: DropdownButtonFormField<String>(
                                value: _selectedFilter,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Filter',
                                  labelStyle:
                                      const TextStyle(color: TColors.darkGrey),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        TSizes.cardRadiusLg),
                                    borderSide: const BorderSide(
                                        color: TColors.darkGrey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        TSizes.cardRadiusLg),
                                    borderSide: const BorderSide(
                                        color: TColors.darkGrey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        TSizes.cardRadiusLg),
                                    borderSide: const BorderSide(
                                        color: TColors.primary),
                                  ),
                                  filled: true,
                                  fillColor: TColors.light,
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
                  // Results Section
                  if (filteredProviders.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48, color: TColors.grey),
                            const SizedBox(height: TSizes.spaceBtwItems),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No healthcare providers found'
                                  : 'No results found for "${_searchQuery}"',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (_selectedFilter != 'All')
                              Text(
                                'with status: $_selectedFilter',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: TColors.grey,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        itemCount: filteredProviders.length,
                        itemBuilder: (context, index) {
                          final provider = filteredProviders[index];
                          return Card(
                            margin: const EdgeInsets.only(
                                bottom: TSizes.spaceBtwItems),
                            child: InkWell(
                              onTap: () {
                                Get.to(() =>
                                    AdminApprovalPage(healthcare: provider));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: TSizes.defaultSpace,
                                  horizontal: TSizes.spaceBtwItems,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TCircularImage(
                                          image:
                                              provider.profilePicture.isNotEmpty
                                                  ? provider.profilePicture
                                                  : TImages.facility,
                                          width: 70,
                                          height: 70,
                                          padding: 5,
                                          isNetworkImage: provider
                                              .profilePicture.isNotEmpty,
                                        ),
                                        const SizedBox(
                                            width: TSizes.spaceBtwItems),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                provider.facilityName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(
                                                  height:
                                                      TSizes.spaceBtwItems / 2),
                                              Text('${provider.licenseNumber}'),
                                              const SizedBox(
                                                  height:
                                                      TSizes.spaceBtwItems / 2),
                                              Text(
                                                provider.status == 'Approved'
                                                    ? 'Status: Approved'
                                                    : provider.status ==
                                                            'Pending'
                                                        ? 'Status: Pending'
                                                        : 'Status: Rejected',
                                                style: TextStyle(
                                                  color: provider.status ==
                                                          'Rejected'
                                                      ? TColors.error
                                                      : provider.status ==
                                                              'Approved'
                                                          ? TColors.success
                                                          : TColors.warning,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (provider.status == 'Approved')
                                          const Icon(
                                            Icons.check_circle,
                                            color: TColors.success,
                                            size: 30,
                                          )
                                        else if (provider.status == 'Rejected')
                                          const Icon(
                                            Icons.cancel,
                                            color: TColors.error,
                                            size: 30,
                                          )
                                        else
                                          TextButton(
                                            onPressed: () {
                                              Get.to(() => AdminApprovalPage(
                                                  healthcare: provider));
                                            },
                                            child: const Text('Review'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
