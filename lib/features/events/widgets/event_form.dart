import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'package:asthma_app/utils/constants/sizes.dart';
import 'package:asthma_app/utils/popups/loaders.dart';
import 'package:asthma_app/features/asthma/screens/healthcare_page/healthcare_navigation_menu.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventForm extends StatefulWidget {
  final String healthcareId;
  final EventModel? event;

  const EventForm({
    Key? key,
    required this.healthcareId,
    this.event,
  }) : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _eventController = Get.find<EventController>();
  bool get isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with controller values
    if (isEditing) {
      _eventController.eventName.text = widget.event!.eventName;
      _eventController.time.text = widget.event!.time;
      _eventController.date.text = widget.event!.date;
      _eventController.location.text = widget.event!.location;
      _eventController.details.text = widget.event!.details;
      _eventController.numberOfParticipant.text =
          widget.event!.numberOfParticipant.toString();
    } else {
      _eventController.eventName.text = '';
      _eventController.time.text = '';
      _eventController.date.text = '';
      _eventController.location.text = '';
      _eventController.details.text = '';
      _eventController.numberOfParticipant.text = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _eventController.date.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventController.time.text = picked.format(context);
      });
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.event != null) {
      await _eventController.deleteEvent(
          widget.event!.eventId, widget.healthcareId);
      Get.back();
    }
  }

  Future<void> _submitForm() async {
    if (_eventController.eventFormKey.currentState!.validate()) {
      try {
        if (isEditing) {
          // Update existing event
          final updatedEvent = EventModel(
            eventId: widget.event!.eventId,
            healthcareId: widget.healthcareId,
            eventName: _eventController.eventName.text.trim(),
            time: _eventController.time.text.trim(),
            date: _eventController.date.text.trim(),
            location: _eventController.location.text.trim(),
            details: _eventController.details.text.trim(),
            numberOfParticipant: int.tryParse(
                    _eventController.numberOfParticipant.text.trim()) ??
                0,
            image:
                _eventController.eventImage.value?.path ?? widget.event!.image,
            createdAt: widget.event!.createdAt,
            updatedAt: Timestamp.now(),
          );
          await _eventController.updateEvent(updatedEvent);

          // Show success message
          TLoaders.successSnackBar(
            title: 'Success',
            message: 'Event updated successfully',
          );
        } else {
          // Create new event
          await _eventController.createEvent(
            healthcareId: widget.healthcareId,
          );

          // Show success message
          TLoaders.successSnackBar(
            title: 'Success',
            message: 'Event created successfully',
          );
        }

        // Navigate to the Events page (index 1) using the navigation controller
        HealthcareNavigationController.instance.navigateToPage(1);
      } catch (e) {
        TLoaders.errorSnackBar(
          title: 'Error',
          message:
              'Failed to ${isEditing ? 'update' : 'create'} event. Please try again.',
        );
      }
    }
  }

  Widget _buildImageWidget() {
    return Obx(() {
      if (_eventController.eventImage.value != null) {
        // Show newly picked image
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_eventController.eventImage.value!.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } else if (isEditing && widget.event!.image != null) {
        // Show existing event image
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.event!.image!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        // Show placeholder
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 50,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Event Image',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create New Event'),
        actions: [
          if (isEditing)
            TextButton.icon(
              onPressed: _deleteEvent,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _eventController.eventFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Event Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    _buildImageWidget(),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _eventController.pickImage,
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              TextFormField(
                controller: _eventController.eventName,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields + 4),
              TextFormField(
                controller: _eventController.date,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields + 4),
              TextFormField(
                controller: _eventController.time,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: _selectTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields + 4),
              TextFormField(
                controller: _eventController.location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields + 4),
              TextFormField(
                controller: _eventController.numberOfParticipant,
                decoration: const InputDecoration(
                  labelText: 'Number of Participants',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of participants';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields + 4),
              TextFormField(
                controller: _eventController.details,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                    onPressed:
                        _eventController.isLoading.value ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _eventController.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? 'Update Event' : 'Create Event'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
