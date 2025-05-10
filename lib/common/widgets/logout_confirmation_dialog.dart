import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:asthma_app/data/repositories/authentication/authentication_repository.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({
    super.key,
    this.title = 'Logout',
    this.content = 'Are you sure you want to logout?',
    this.cancelText = 'Cancel',
    this.logoutText = 'Logout',
    this.onLogoutSuccess,
    this.onLogoutError,
  });

  final String title;
  final String content;
  final String cancelText;
  final String logoutText;
  final VoidCallback? onLogoutSuccess;
  final Function(String)? onLogoutError;

  /// Show the logout confirmation dialog
  static Future<void> show({
    required BuildContext context,
    String title = 'Logout',
    String content = 'Are you sure you want to logout?',
    String cancelText = 'Cancel',
    String logoutText = 'Logout',
    VoidCallback? onLogoutSuccess,
    Function(String)? onLogoutError,
  }) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => LogoutConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        logoutText: logoutText,
        onLogoutSuccess: onLogoutSuccess,
        onLogoutError: onLogoutError,
      ),
    );

    // If user confirmed logout
    if (shouldLogout == true) {
      try {
        // Call logout function from authentication repository
        await AuthenticationRepository.instance.logout();

        // Call success callback if provided
        if (onLogoutSuccess != null) {
          onLogoutSuccess!();
        }
      } catch (e) {
        // Call error callback if provided
        if (onLogoutError != null) {
          onLogoutError!(e.toString());
        } else {
          // Default error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(logoutText),
        ),
      ],
    );
  }
}
