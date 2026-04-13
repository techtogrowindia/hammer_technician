import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class ExitConfirmation {
  static Future<bool> show(
    BuildContext context, {
    required String message,
    String title = 'Are you sure?',
    String confirmText = 'Yes',
    String cancelText = 'No',
    bool closeApp = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              if (closeApp) {
                SystemNavigator.pop(); // closes the app
              } else {
                Navigator.pop(context, true); // let caller handle
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
