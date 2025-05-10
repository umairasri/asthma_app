import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asthma_app/utils/popups/full_screen_loader.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/utils/constants/image_strings.dart';
import 'package:asthma_app/utils/helpers/network_manager.dart';
import 'package:asthma_app/utils/logger.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import 'package:flutter/material.dart';

class EventController extends GetxController {
  final EventRepository _eventRepository = EventRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<XFile?> eventImage = Rx<XFile?>(null);
  final RxString selectedFilter = 'All'.obs;

  // Form controllers
  final eventName = TextEditingController();
  final time = TextEditingController();
  final date = TextEditingController();
  final location = TextEditingController();
  final details = TextEditingController();
  final numberOfParticipant = TextEditingController();
  GlobalKey<FormState> eventFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    eventName.dispose();
    time.dispose();
    date.dispose();
    location.dispose();
    details.dispose();
    numberOfParticipant.dispose();
    super.onClose();
  }

  // Helper method to create a DocumentReference from healthcareId
  DocumentReference _getHealthcareRef(String healthcareId) {
    return _firestore.collection('Healthcare').doc(healthcareId);
  }

  Future<bool> _validateHealthcare(String healthcareId) async {
    try {
      TLogger.info('Validating healthcare ID: $healthcareId');

      // First check if the ID is not empty
      if (healthcareId.isEmpty) {
        TLoaders.errorSnackBar(
            title: 'Error', message: 'Healthcare ID is empty');
        return false;
      }

      // Check if the document exists
      final healthcareDoc =
          await _firestore.collection('Healthcare').doc(healthcareId).get();

      if (!healthcareDoc.exists) {
        TLogger.error('Healthcare provider not found with ID: $healthcareId');
        TLoaders.errorSnackBar(
            title: 'Error',
            message:
                'Healthcare provider not found. Please check your healthcare ID.');
        return false;
      }

      // Log the healthcare data for debugging
      TLogger.info('Healthcare document found: ${healthcareDoc.data()}');
      return true;
    } catch (e) {
      TLogger.error('Failed to validate healthcare provider: $e');
      TLoaders.errorSnackBar(
          title: 'Error',
          message: 'Failed to validate healthcare provider: $e');
      return false;
    }
  }

  Future<void> createEvent({
    required String healthcareId,
  }) async {
    try {
      TLogger.info('Creating event for healthcare ID: $healthcareId');

      // Start Loading
      TFullScreenLoader.openLoadingDialog(
          'Creating event...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Validate healthcare exists
      final isValidHealthcare = await _validateHealthcare(healthcareId);
      if (!isValidHealthcare) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!eventFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Create new event
      final newEvent = EventModel(
        eventId: _firestore.collection('Events').doc().id,
        healthcareId: healthcareId,
        eventName: eventName.text.trim(),
        time: time.text.trim(),
        date: date.text.trim(),
        location: location.text.trim(),
        details: details.text.trim(),
        numberOfParticipant: int.tryParse(numberOfParticipant.text.trim()) ?? 0,
        image: eventImage.value?.path,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      // Save to Firestore
      await _eventRepository.createEvent(newEvent);

      // Update UI
      events.add(newEvent);

      // Clear form
      clearForm();

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Message
      TLoaders.successSnackBar(
          title: 'Success', message: 'Event created successfully');

      // Navigate back
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLogger.error('Failed to create event: $e');
      TLoaders.errorSnackBar(
          title: 'Error', message: 'Failed to create event. Please try again.');
    }
  }

  /// Clear form
  void clearForm() {
    eventName.clear();
    time.clear();
    date.clear();
    location.clear();
    details.clear();
    numberOfParticipant.clear();
    eventImage.value = null;
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        eventImage.value = image;
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Oh Snap!', message: 'Failed to pick image: $e');
    }
  }

  Future<void> getEventsByHealthcareId(String healthcareId) async {
    try {
      isLoading.value = true;
      final eventList =
          await _eventRepository.getEventsByHealthcareId(healthcareId);
      events.assignAll(eventList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      isLoading.value = true;
      return await _eventRepository.getEventById(eventId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch event: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      isLoading.value = true;
      await _eventRepository.updateEvent(event);
      await getEventsByHealthcareId(event.healthcareId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId, String healthcareId) async {
    try {
      isLoading.value = true;
      await _eventRepository.deleteEvent(eventId);
      await getEventsByHealthcareId(healthcareId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateParticipantCount(String eventId, int newCount) async {
    try {
      isLoading.value = true;
      await _eventRepository.updateParticipantCount(eventId, newCount);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update participant count: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllEvents() async {
    try {
      isLoading.value = true;
      final eventList = await _eventRepository.getAllEvents();
      events.assignAll(eventList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch events: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<EventModel> getPastEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return events.where((event) {
      try {
        final parts = event.date.split('/');
        if (parts.length != 3) return false;

        final eventDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final eventDay =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

        return eventDay.isBefore(today);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return events.where((event) {
      try {
        final parts = event.date.split('/');
        if (parts.length != 3) return false;

        final eventDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final eventDay =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

        return !eventDay.isBefore(today);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
