import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/providers/training_provider.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_lesson_training_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/top_image_layout.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_loading_indicator.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  @override
  void initState() {
    super.initState();
    // טעינת הנתונים אחרי שה-widget נבנה במלואו
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trainingProvider =
          Provider.of<TrainingProvider>(context, listen: false);

      // תמיד לנקות שגיאות קודמות בכניסה למסך
      if (trainingProvider.error != null) {
        trainingProvider.clearError();
      }

      // בדיקה אם צריך לטעון נתונים
      if (trainingProvider.currentProgram == null ||
          trainingProvider.lessons.isEmpty) {
        _loadTrainingData();
      }
    });
  }

  Future<void> _loadTrainingData() async {
    print('Starting to load training data...');
    final trainingProvider =
        Provider.of<TrainingProvider>(context, listen: false);

    // ניקוי שגיאות קודמות
    trainingProvider.clearError();

    // במקום לטעון תוכנית ספציפית, נטען את כל התוכניות
    // ונבחר את הראשונה מהרשימה
    try {
      await trainingProvider.loadTrainingPrograms();
      if (trainingProvider.programs.isNotEmpty) {
        final firstProgramId = trainingProvider.programs.first.id;
        print('Loading first available training program: $firstProgramId');
        await trainingProvider.loadTrainingProgram(firstProgramId);
      } else {
        print('No training programs available.');
      }
    } catch (e) {
      print('Error loading training data: $e');
    }

    print('Training data loaded successfully');
    print('Current program: ${trainingProvider.currentProgram?.title}');
    print('Number of lessons: ${trainingProvider.lessons.length}');
    print('Error: ${trainingProvider.error}');
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Consumer<TrainingProvider>(
      builder: (context, trainingProvider, child) {
        // מצב טעינה
        if (trainingProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppLoadingIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'טוען נתוני אימונים...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // מצב שגיאה - רק אם לא בטעינה
        if (trainingProvider.error != null && !trainingProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'שגיאה בטעינת נתוני האימונים',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'אירעה שגיאה. נסה שוב מאוחר יותר.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      label: 'נסה שוב',
                      action: 'retry',
                      onPressed: () {
                        trainingProvider.clearError();
                        _loadTrainingData();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // אם אין תוכנית נוכחית (שגיאה בטעינה)
        if (trainingProvider.currentProgram == null) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'לא ניתן לטעון את תוכנית האימון',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'נסה שוב מאוחר יותר',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      label: 'נסה שוב',
                      action: 'retry',
                      onPressed: () {
                        trainingProvider.clearError();
                        _loadTrainingData();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final program = trainingProvider.currentProgram;
        final lessons = trainingProvider.lessons;

        return TopImageLayout(
          title: 'בית ספר להצלחה',
          imageSrc: 'images/school.png',
          darkLinear: true,
          formKey: _formKey,
          showBackButton: true,
          cardChildren: [
            if (program != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    context: context,
                    icon: Icons.video_library,
                    label: 'שיעורים',
                    value: '${lessons.length}/${program.totalLessons}',
                  ),
                  _buildInfoItem(
                    context: context,
                    icon: Icons.timer,
                    label: 'משך כולל',
                    value: program.estimatedDuration > 0
                        ? '${program.estimatedDuration} דקות'
                        : 'לא מוגדר',
                  ),
                  _buildInfoItem(
                    context: context,
                    icon: Icons.trending_up,
                    label: 'התקדמות',
                    value:
                        '${trainingProvider.getOverallProgress().toStringAsFixed(0)}%',
                  ),
                ],
              ),

              // תיאור התוכנית
              if (program.description.isNotEmpty) ...[
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    program.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ],
          ],
          additionalChildren: [
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.school,
                              size: 60,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'תכנית הלימודים',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    AppDivider(
                      xMargin: 0,
                      height: 2,
                    ),

                    const SizedBox(height: 20),

                    // אם אין שיעורים
                    if (lessons.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'אין שיעורים זמינים',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'שיעורים יתווספו בקרוב',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Column(
                        children: lessons.map((lesson) {
                          final isLocked =
                              !trainingProvider.isLessonAccessible(lesson.id);
                          final isCompleted =
                              trainingProvider.checkLessonCompletion(lesson.id);
                          final progress =
                              trainingProvider.getLessonProgress(lesson.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppLessonTrainingCard(
                              title: lesson.title,
                              subtitle: '${lesson.duration} דקות',
                              lessonNumber: lesson.lessonNumber,
                              isLocked: isLocked,
                              isCompleted: isCompleted,
                              progress: progress,
                              hasVideo: lesson.media?.videoUrl != null,
                              videoDuration:
                                  lesson.media?.videoDuration.toInt() ?? 0,
                              onTap: isLocked
                                  ? null
                                  : () async {
                                      if (!isLocked) {
                                        // התחלת השיעור בשרת
                                        await trainingProvider
                                            .startLesson(lesson.id);
                                        context.push(
                                            '/training/lesson/${lesson.id}');
                                      }
                                    },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
