import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:asthma_app/utils/constants/colors.dart';

class AsthmaInformationScreen extends StatelessWidget {
  const AsthmaInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Asthma Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                labelStyle: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
                labelColor: TColors.primary,
                unselectedLabelColor: Colors.black54,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: TColors.primary),
                  insets: const EdgeInsets.symmetric(horizontal: 24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'What is\nAsthma?'),
                  Tab(text: 'What Triggers\nAsthma?'),
                  Tab(text: 'Could I Have\nSevere Asthma?'),
                  Tab(text: 'Asthma\nMedications'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _WhatIsAsthmaTab(),
            _WhatTriggersAsthmaTab(),
            _SevereAsthmaTab(),
            _AsthmaMedicationsTab(),
          ],
        ),
        backgroundColor: const Color(0xFFF7F8FA),
      ),
    );
  }
}

class _WhatIsAsthmaTab extends StatelessWidget {
  const _WhatIsAsthmaTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'What is Asthma?',
            color: TColors.primary,
            icon: Icons.info_outline,
            child: const Text(
              'Asthma is a chronic disease that causes inflammation in the lungs, which narrows the airways, making it more difficult for sufferers to breathe. There is no cure, but it can be managed with the right treatment and knowledge.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          _SectionCard(
            title: 'Type of Asthma',
            color: TColors.secondary,
            icon: Icons.category_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Not all asthma is the same. It may be different for different people.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                SizedBox(height: 16),
                _AsthmaTypeText(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AsthmaTypeText extends StatelessWidget {
  const _AsthmaTypeText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Intermittent Asthma',
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
            '> Intermittent asthma is the mildest form of asthma and has very little impact on your daily life.'),
        SizedBox(height: 12),
        Text(
          'Mild Persistent Asthma',
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
            '> Mild persistent asthma may have a minor impact on your daily life and your physical activity. It can often be controlled by using a rescue inhaler when necessary and with doctor-prescribed long-term controller medication.'),
        SizedBox(height: 12),
        Text(
          'Moderate Persistent Asthma',
          style: TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
            '> Moderate persistent asthma will likely put increased limitations on your daily physical activity and your lung function tests may show that your breathing is impaired. Your doctor may prescribe a long-term controller medication.'),
        SizedBox(height: 12),
        Text(
          'Severe Persistent Asthma',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
            '> If you have severe persistent asthma, you experience symptoms every day, may need a rescue inhaler several times a day, and your activities are significantly limited.'),
      ],
    );
  }
}

class _WhatTriggersAsthmaTab extends StatelessWidget {
  const _WhatTriggersAsthmaTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'What Triggers Asthma?',
            color: TColors.primary,
            icon: Icons.warning_amber_rounded,
            child: const Text(
              "Asthma symptoms and attacks can be triggered by exposure to a variety of toxic and non-toxic elements, irritants in the air, activities, and conditions that can aggravate your lungs. Triggers vary between sufferers, so it's best to know your own triggers and avoid exposure to them as much as possible.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              'Common Asthma Triggers',
              style: TextStyle(
                color: TColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _AsthmaTriggersGrid(),
        ],
      ),
    );
  }
}

class _AsthmaTriggersGrid extends StatelessWidget {
  const _AsthmaTriggersGrid();

  @override
  Widget build(BuildContext context) {
    final triggers = [
      {'icon': Icons.smoking_rooms, 'label': 'Smoking'},
      {'icon': Icons.fastfood, 'label': 'Food Sensitivities'},
      {'icon': Icons.fitness_center, 'label': 'Exercise'},
      {'icon': Icons.psychology, 'label': 'Stress'},
      {'icon': Icons.bug_report, 'label': 'Dust Mites'},
      {'icon': Icons.grass, 'label': 'Allergies & Pollen'},
      {'icon': Icons.air, 'label': 'Air Quality'},
      {'icon': Icons.sick, 'label': 'Illnesses'},
      {'icon': Icons.medication, 'label': 'Medications'},
      {'icon': Icons.pets, 'label': 'Pets'},
      {'icon': Icons.warning, 'label': 'Strong Odors'},
      {'icon': Icons.cloud, 'label': 'Weather Changes'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: triggers.length,
      itemBuilder: (context, index) {
        final trigger = triggers[index];
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(trigger['icon'] as IconData,
                    size: 32, color: TColors.primary),
                const SizedBox(height: 8),
                Text(
                  trigger['label'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SevereAsthmaTab extends StatelessWidget {
  const _SevereAsthmaTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What is Severe Asthma
          _SectionCard(
            title: 'What Is\nSevere Asthma',
            color: Colors.orange,
            child: const Text(
              'People with severe asthma experience symptoms throughout the day, often have their sleep disrupted at night, may need their rescue inhalers multiple times a week (sometimes daily), and might have to put limits on their daily activity. Asthma attacks can be common, and may require urgent care, ER, or hospital visits and treatment with oral steroids.\n\nSevere asthma can also remain uncontrolled despite consistently following their prescribed medication routine.',
              style: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),

          // Type of Severe Asthma
          _SectionCard(
            title: 'Type of\nSevere Asthma',
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Column(
                  children: [
                    Icon(Icons.face, size: 40), // Replace with allergy icon
                    SizedBox(height: 8),
                    Text('Allergy Asthma'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.face_retouching_off,
                        size: 40), // Replace with nonallergy icon
                    SizedBox(height: 8),
                    Text('Nonallergy Asthma'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Eosinophils & Asthma
          _SectionCard(
            title: 'Eosinophils\n& Asthma',
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About 50% of people with severe asthma have high levels of eosinophils—white blood cells that normally support the immune system. In eosinophilic asthma, these elevated cells cause ongoing lung inflammation, contributing to asthma development.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.face,
                              size: 32), // Replace with eosinophil icon
                          SizedBox(height: 8),
                          Text(
                            'Eosinophils can respond to common asthma triggers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(Icons.face, size: 32), // Replace with lung icon
                          SizedBox(height: 8),
                          Text(
                            'Active eosinophils can build up in your airways and cause inflammation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Severe Asthma & Uncontrolled Asthma (light section)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Severe Asthma & Uncontrolled Asthma',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Severe asthma is not the same as uncontrolled asthma. Uncontrolled asthma means frequent symptoms that affect daily life. If not treated, it can cause more attacks and harm the lungs.",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Four features grid
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _UncontrolledAsthmaFeature(
                      icon: Icons.sentiment_dissatisfied,
                      title: 'Poor Symptom Control',
                      description:
                          'Even when regularly taking medication, your symptoms are frequent and difficult to manage',
                      isLight: true,
                    ),
                    _UncontrolledAsthmaFeature(
                      icon: Icons.medication,
                      title: 'Two or More Severe Asthma Attacks in a Year',
                      description:
                          'Needing 2 or more courses of oral steroids due to worsening symptoms over the past year',
                      isLight: true,
                    ),
                    _UncontrolledAsthmaFeature(
                      icon: Icons.local_hospital,
                      title: 'Multiple Hospital Visits',
                      description:
                          "If you've had more than one hospitalization due to an asthma attack in the past 12 months",
                      isLight: true,
                    ),
                    _UncontrolledAsthmaFeature(
                      icon: Icons.nightlight_round,
                      title: 'Recurring Nighttime Flare-ups',
                      description: "You're awakened by your asthma symptoms",
                      isLight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UncontrolledAsthmaFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLight;

  const _UncontrolledAsthmaFeature({
    required this.icon,
    required this.title,
    required this.description,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isLight ? Colors.black87 : Colors.white;
    final iconBg = isLight ? Colors.grey.shade100 : Colors.white10;
    final iconColor = isLight ? Colors.teal : Colors.teal;
    return SizedBox(
      width: 150,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: iconBg,
            radius: 32,
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: textColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _AsthmaMedicationsTab extends StatelessWidget {
  const _AsthmaMedicationsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning/info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Asthma medications have certain risks and side effects. Your healthcare provider will discuss these with you when determining which treatment option, if any, is right for you.',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Quick Relief vs Long-Term Control
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Quick Relief vs Long-Term Control',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  'Some people experience mild, infrequent symptoms and may only need quick-relief medications. Others suffer from frequent and persistent symptoms that require long-term controller medications. Consult your doctor or asthma specialist to determine the best course of treatment for your type of asthma.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Rescue/Quick Relief
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.flash_on, color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Rescue/Quick Relief:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BulletPoint(text: 'Treats sudden asthma symptoms'),
                _BulletPoint(
                    text:
                        'Relaxes the muscles around the airways of the lungs'),
                _BulletPoint(
                    text:
                        'Typically delivered by an inhaler—or nebulizer if needed'),
                _BulletPoint(
                    text: 'Portable and should be accessible at all times'),
              ],
            ),
          ),

          // Long-Term Control
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.hourglass_bottom,
                        color: Colors.orange, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Long-Term Control:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BulletPoint(
                    text:
                        'Taken daily or at regular intervals regardless of symptom frequency'),
                _BulletPoint(
                    text:
                        'Used for preventing, not relieving symptoms on the spot'),
                _BulletPoint(
                    text: 'Reduces inflammation in the airways of the lungs'),
                _BulletPoint(text: 'Can be inhalers, pills, or injections'),
                _BulletPoint(
                    text:
                        'Multiple medications can be combined and delivered in a single inhaler'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 18, color: Colors.orange)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color color;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  const _SectionCard({
    required this.title,
    required this.child,
    required this.color,
    this.icon,
    this.iconColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: iconColor ?? color, size: 26),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
