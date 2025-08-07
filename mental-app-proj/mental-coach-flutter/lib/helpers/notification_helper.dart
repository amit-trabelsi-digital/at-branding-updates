import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/notifies/app_match_details_draw.dart';
import 'package:mental_coach_flutter_firebase/widgets/notifies/app_notify_draw.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_score_notify.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';

void showAppNotifyDraw(
  BuildContext context, {
  Widget? child,
  Match? currentMatch,
  String title = 'התראה',
  String message = 'הודעה',
  String primaryButtonLabel = 'אישור',
  String? primaryButtonAction,
  VoidCallback? onPrimaryButtonPressed,
  String? secondaryButtonLabel,
  VoidCallback? onSecondaryButtonPressed,
  String? audioUrl,
  String? audioImageUrl,
  double heightRatio = 0.65,
  bool isPersistent = false,
  bool permanent = false,
  int seconds = 10,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => AppNotifyDraw(
      title: title,
      message: message,
      primaryButtonLabel: primaryButtonLabel,
      primaryButtonAction: primaryButtonAction,
      onPrimaryButtonPressed: onPrimaryButtonPressed ??
          () {
            if (overlayEntry.mounted) {
              overlayEntry.remove();
            }
          },
      secondaryButtonLabel: secondaryButtonLabel,
      onSecondaryButtonPressed: onSecondaryButtonPressed,
      audioUrl: audioUrl,
      audioImageUrl: audioImageUrl,
      heightRatio: heightRatio,
      overlayEntry: overlayEntry,
      child: child,
    ),
  );

  overlay.insert(overlayEntry);

  // If not permanent and not persistent, remove after specified seconds
  if (!permanent && !isPersistent) {
    Future.delayed(Duration(seconds: seconds), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

void showAppMatchNotifyDraw(BuildContext context,
    {Widget? child,
    required Match currentMatch,
    bool isPersistent = false,
    bool permanent = true,
    int seconds = 10}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => AppMatchNotifyDraw(
      overlayEntry: overlayEntry,
      match: currentMatch,
    ),
  );

  overlay.insert(overlayEntry);

  if (!permanent && !isPersistent) {
    Future.delayed(Duration(seconds: seconds), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

void showScoreNotification(BuildContext context, int score) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return GestureDetector(
        onTap: () {
          if (overlayEntry.mounted) {
            overlayEntry.remove(); // Remove the notification on tap
          }
        },
        child: Material(
          color: Colors
              .transparent, // Ensures the overlay doesn't block the screen
          child: ScoreNotificationWidget(score: score),
        ),
      );
    },
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  // Remove the overlay entry after a duration
  Future.delayed(Duration(seconds: 8), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// התראה בסיסית עם כותרת בלבד
// void showBasicNotification(BuildContext context, String title,
//     {bool isPersistent = false}) {
//   showAppNotification(
//     context,
//     title: title,
//     type: NotificationType.basic,
//     isPersistent: isPersistent,
//   );
// }

// // התראה עם כותרת ותוכן
// void showContentNotification(BuildContext context, String title, String content,
//     {bool isPersistent = false}) {
//   showAppNotification(
//     context,
//     title: title,
//     content: content,
//     type: NotificationType.withContent,
//     isPersistent: isPersistent,
//   );
// }

// // התראה עם נגן אודיו
// void showAudioNotification(
//     BuildContext context, String title, String content, String audioPath,
//     {String? imageUrl,
//     String? buttonText,
//     VoidCallback? onButtonPressed,
//     VoidCallback? onClose,
//     bool isPersistent = true,
//     int autoCloseSeconds = 20}) {
//   showAppNotification(
//     context,
//     title: title,
//     content: content,
//     audioUrl: UrlSource(audioPath),
//     imageUrl: imageUrl,
//     type: buttonText != null
//         ? NotificationType.withAudioButtons
//         : NotificationType.withAudio,
//     isPersistent: isPersistent,
//     primaryButtonText: buttonText,
//     primaryButtonAction: onButtonPressed,
//     onClose: onClose,
//     autoCloseSeconds: autoCloseSeconds,
//   );
// }

// // התראה עם כפתורים
// void showActionNotification(BuildContext context, String title, String content,
//     String buttonText, VoidCallback onPressed,
//     {VoidCallback? onClose, bool isPersistent = true}) {
//   showAppNotification(
//     context,
//     title: title,
//     content: content,
//     primaryButtonText: buttonText,
//     primaryButtonAction: onPressed,
//     onClose: onClose,
//     type: NotificationType.withButtons,
//     isPersistent: isPersistent,
//   );
// }
