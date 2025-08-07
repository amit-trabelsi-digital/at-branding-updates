import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/players/app_audio_player.dart';

enum NotificationType {
  basic, // רק כותרת
  withContent, // כותרת ותיאור
  withAudio, // כותרת, תיאור ונגן
  withButtons, // כותרת, תיאור וכפתורים
  withAudioButtons // כותרת, תיאור, נגן וכפתורים
}

class AppNotification extends StatelessWidget {
  final String title;
  final String? content;
  final Source? audioUrl;
  final String? imageUrl;
  final String? primaryButtonText;
  final VoidCallback? primaryButtonAction;
  final VoidCallback? onClose;
  final NotificationType type;
  final Color backgroundColor;

  const AppNotification({
    super.key,
    required this.title,
    this.content,
    this.audioUrl,
    this.imageUrl,
    this.primaryButtonText,
    this.primaryButtonAction,
    this.onClose,
    this.type = NotificationType.basic,
    this.backgroundColor = Colors.white,
  });

  // Helper function to get the right color based on notification type
  Color _getNotificationColor() {
    switch (type) {
      case NotificationType.basic:
        return AppColors.lightPurple;
      case NotificationType.withContent:
        return AppColors.lightGrey;
      case NotificationType.withAudio:
        return Colors.white;
      case NotificationType.withButtons:
        return Colors.white;
      default:
        return AppColors.lightPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor == Colors.white
            ? _getNotificationColor()
            : backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת עם אופציה לכפתור סגירה
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (type == NotificationType.basic ||
                    type == NotificationType.withContent)
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Barlev',
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),

          // תוכן אופציונלי
          if (content != null &&
              (type == NotificationType.withContent ||
                  type == NotificationType.withAudio ||
                  type == NotificationType.withButtons ||
                  type == NotificationType.withAudioButtons))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

          // נגן אודיו אופציונלי
          if (audioUrl != null &&
              (type == NotificationType.withAudio ||
                  type == NotificationType.withAudioButtons))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AudioWidget(
                audioUrl: audioUrl is Source
                    ? (audioUrl as UrlSource).url
                    : audioUrl.toString(),
                imageUrl: imageUrl ?? 'images/eitan.png',
              ),
            ),

          // כפתורים אופציונליים
          if (primaryButtonText != null &&
              (type == NotificationType.withButtons ||
                  type == NotificationType.withAudioButtons))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: primaryButtonAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        primaryButtonText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (onClose != null)
                    TextButton(
                      onPressed: onClose,
                      child: const Text(
                        'אני מוותר',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// פונקציה להצגת ההתראה
void showAppNotification(
  BuildContext context, {
  required String title,
  String? content,
  Source? audioUrl,
  String? imageUrl,
  String? primaryButtonText,
  VoidCallback? primaryButtonAction,
  VoidCallback? onClose,
  NotificationType type = NotificationType.basic,
  Color backgroundColor = Colors.white,
  bool isPersistent = false,
  int autoCloseSeconds = 5,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: AppNotification(
            title: title,
            content: content,
            audioUrl: audioUrl,
            imageUrl: imageUrl,
            primaryButtonText: primaryButtonText,
            primaryButtonAction: primaryButtonAction,
            onClose: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
              onClose?.call();
            },
            type: type,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // אם ההתראה אינה קבועה, סגור אותה אוטומטית אחרי זמן מוגדר
  if (!isPersistent) {
    Future.delayed(Duration(seconds: autoCloseSeconds), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
