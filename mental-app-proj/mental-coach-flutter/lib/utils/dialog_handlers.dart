import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';

Future<void> handleEntityDelete<T>({
  required BuildContext context,
  required String entityId,
  required String entityType,
  required String entityDisplayName,
  VoidCallback? onSuccessCallback,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('אישור מחיקה'),
        content: Text('האם אתה בטוח שברצונך למחוק את ה$entityDisplayName הזה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog
              Navigator.of(dialogContext).pop();

              // Store a reference to the UserProvider before async operation
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              // Get a BuildContext that we can use for the loading dialog
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) {
                  return const Center(child: CircularProgressIndicator());
                },
              );

              try {
                "Calling API to delete the entity".green.log();
                // Call API to delete the entity
                final response = await AppFetch.fetch(
                  '$entityType/$entityId',
                  method: 'PUT',
                  body: {
                    'visible': false,
                    'isOpen': false
                  }, // Add a proper JSON body
                );

                "Response status: ${response.statusCode}".green.log();

                // Check if the widget is still mounted before using context
                if (!context.mounted) return;

                if (response.statusCode == 200) {
                  // Update user data using the stored userProvider reference
                  userProvider.removeMatch(entityId);

                  // Call the success callback if provided
                  if (onSuccessCallback != null) {
                    "inside if".green.log();
                    onSuccessCallback();
                  }

                  // Show success message
                  Navigator.of(context, rootNavigator: true).pop();

                  if (context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                          content: Text('ה$entityDisplayName נמחק בהצלחה')),
                    );
                  }
                } else {
                  // Show error message
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                          content: Text('שגיאה במחיקת ה$entityDisplayName')),
                    );
                  }
                }
              } catch (e) {
                // Check if the widget is still mounted before using context
                if (!context.mounted) return;

                // Close loading dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Show error message
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('שגיאה: ${e.toString()}')),
                );
              }
            },
            child: const Text('מחק'),
          ),
        ],
      );
    },
  );
}
