import 'package:asthma_app/data/repositories/reminder/reminder_repository.dart';
import 'package:asthma_app/features/personalization/screens/settings/settings.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:asthma_app/features/reminder/models/reminder_model.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';

class ReminderController extends GetxController {
  static ReminderController get instance => Get.find();

  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final _repo = ReminderRepository();
  GlobalKey<FormState> reminderFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    reminders.bindStream(_repo.getUserReminders());
    super.onInit();
  }

  Future<void> addReminder({
    required String title,
    required String color,
    required String time,
    required String date,
    required String repeat,
    required String ringtone,
    required String details,
  }) async {
    try {
      // Form Validation
      if (!reminderFormKey.currentState!.validate()) {
        return;
      }

      final reminder = ReminderModel(
        id: const Uuid().v4(),
        userId: AuthenticationRepository.instance.authUser!.uid,
        title: title,
        color: color,
        time: time,
        date: date,
        repeat: repeat,
        ringtone: ringtone,
        details: details,
      );
      await _repo.addReminder(reminder);

      // Popup Success Notification
      TLoaders.successSnackBar(title: 'Saved!', message: 'Reminder recorded.');

      // Redirect Screen
      Get.to(() => const SettingScreen());
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to save: $e');
    }
  }
}
