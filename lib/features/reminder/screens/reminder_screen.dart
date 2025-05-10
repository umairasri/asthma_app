import 'package:asthma_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/features/reminder/controllers/reminder_controller.dart';

class ReminderScreen extends StatelessWidget {
  final controller = Get.put(ReminderController());

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final RxString selectedColor = 'green'.obs;
  final RxString time = ''.obs;
  final RxString date = ''.obs;
  final RxString repeat = 'Once'.obs;
  final RxString ringtone = 'Alarm clock'.obs;

  ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Reminder")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.reminderFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                validator: (value) =>
                    TValidator.validateEmptyText('Title', value),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['green', 'blue', 'pink', 'red', 'orange']
                    .map((color) => Obx(() => GestureDetector(
                          onTap: () => selectedColor.value = color,
                          child: CircleAvatar(
                            backgroundColor: Colors.primaries[[
                              'green',
                              'blue',
                              'pink',
                              'red',
                              'orange'
                            ].indexOf(color)],
                            child: selectedColor.value == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        )))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Time"),
                trailing: Obx(
                    () => Text(time.value.isEmpty ? "All-day" : time.value)),
                onTap: () async {
                  final selected = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (selected != null) time.value = selected.format(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text("Date"),
                trailing: Obx(() =>
                    Text(date.value.isEmpty ? "Select Date" : date.value)),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    date.value =
                        "${selected.day} ${_monthName(selected.month)} ${selected.year}";
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text("Repeat"),
                trailing: Obx(() => Text(repeat.value)),
                onTap: () =>
                    _showOptions(context, repeat, ['Once', 'Daily', 'Weekly']),
              ),
              ListTile(
                leading: const Icon(Icons.alarm),
                title: const Text("Ringtone"),
                trailing: Obx(() => Text(ringtone.value)),
                onTap: () => _showOptions(
                    context, ringtone, ['Alarm clock', 'Beep', 'Buzz']),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => controller.addReminder(
                  title: titleController.text.trim(),
                  color: selectedColor.value,
                  time: time.value,
                  date: date.value,
                  repeat: repeat.value,
                  ringtone: ringtone.value,
                  details: detailsController.text.trim(),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(
      BuildContext context, RxString target, List<String> options) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: options
            .map((opt) => ListTile(
                  title: Text(opt),
                  onTap: () {
                    target.value = opt;
                    Get.back();
                  },
                ))
            .toList(),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
