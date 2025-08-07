import 'package:flutter/material.dart';

class AppLessonTrainingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? shortTitle;
  final int lessonNumber;
  final bool isLocked;
  final bool isCompleted;
  final int progress;
  final bool hasVideo;
  final int videoDuration;
  final VoidCallback? onTap;

  const AppLessonTrainingCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.shortTitle,
    required this.lessonNumber,
    this.isLocked = false,
    this.isCompleted = false,
    this.progress = 0,
    this.hasVideo = false,
    this.videoDuration = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 5,
              offset: Offset(0, 0),
              spreadRadius: 0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // מספר שיעור ואייקון
              Container(
                width: 30,
                height: 60,
                child: Center(
                  child: Text(
                    lessonNumber.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 40,
                      fontFamily: 'Barlev',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // תוכן השיעור
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shortTitle != null && shortTitle!.isNotEmpty) ...[
                      Text(
                        shortTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? Colors.grey : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // if (hasVideo) ...[
                        //   Icon(
                        //     Icons.play_circle_outline,
                        //     size: 16,
                        //     color: Colors.grey[600],
                        //   ),
                        //   const SizedBox(width: 4),
                        //   Text(
                        //     '${videoDuration} דקות',
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       color: Colors.grey[600],
                        //     ),
                        //   ),
                        //   const SizedBox(width: 12),
                        // ],
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // פס התקדמות
                    if (!isLocked && progress > 0 && !isCompleted) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // חץ לפתיחה
              if (isLocked)
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Colors.grey[600],
                )
              else if (isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Colors.green,
                )
              else
                Icon(
                  Icons.play_circle_fill,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
