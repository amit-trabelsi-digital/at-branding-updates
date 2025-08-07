import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/models/training_models.dart';
import 'package:mental_coach_flutter_firebase/providers/training_provider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout_with_nav.dart';
import 'package:provider/provider.dart';

class TrainingExercisePage extends StatefulWidget {
  final String lessonId;
  final String exerciseId;

  const TrainingExercisePage({
    super.key,
    required this.lessonId,
    required this.exerciseId,
  });

  @override
  State<TrainingExercisePage> createState() => _TrainingExercisePageState();
}

class _TrainingExercisePageState extends State<TrainingExercisePage> {
  Exercise? _exercise;
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadExercise(TrainingProvider trainingProvider) {
    if (_isInitialized) return;

    // מוצא את התרגיל
    final exercises = trainingProvider.exercises;
    _exercise = exercises.firstWhere(
      (exercise) => exercise.id == widget.exerciseId,
      orElse: () => exercises.first,
    );

    // יוצר controllers לשדות טקסט
    if (_exercise != null) {
      if (_exercise!.type == 'questionnaire' &&
          _exercise!.content['questions'] != null) {
        final questions = _exercise!.content['questions'] as List;
        for (var question in questions) {
          if (question['type'] == 'text_area' ||
              question['type'] == 'text_input') {
            _controllers[question['id']] = TextEditingController();
          }
        }
      } else if (_exercise!.type == 'action_plan' &&
          _exercise!.content['fields'] != null) {
        final fields = _exercise!.content['fields'] as List;
        for (var field in fields) {
          _controllers[field['name']] = TextEditingController();
        }
      }
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitExercise(TrainingProvider trainingProvider) {
    // בודק אם כל השדות הנדרשים מולאו
    bool isValid = true;
    String errorMessage = '';

    if (_exercise!.type == 'questionnaire') {
      final questions = _exercise!.content['questions'] as List;
      for (var question in questions) {
        if (question['required'] == true) {
          final answer = _answers[question['id']];
          if (answer == null || (answer is String && answer.isEmpty)) {
            isValid = false;
            errorMessage = 'יש למלא את כל השדות הנדרשים';
            break;
          }
        }
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // שומר את התשובות ומעדכן התקדמות
    trainingProvider.updateLessonProgress(widget.lessonId, 100);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('התרגיל הושלם בהצלחה!'),
        backgroundColor: Colors.green,
      ),
    );

    // חוזר למסך השיעור
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrainingProvider(),
      child: Consumer<TrainingProvider>(
        builder: (context, trainingProvider, child) {
          // טוען את הנתונים בפעם הראשונה
          if (!_isInitialized && trainingProvider.exercises.isNotEmpty) {
            _loadExercise(trainingProvider);
          }

          if (_exercise == null) {
            return const AppPageLayout(
              title: 'טוען...',
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return AppPageLayout(
            title: _exercise!.title,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // תיאור התרגיל
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            _getExerciseIcon(_exercise!.type),
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _exercise!.description,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          if (_exercise!.settings.timeLimit > 0) ...[
                            const SizedBox(height: 10),
                            Text(
                              'זמן מומלץ: ${_exercise!.settings.timeLimit ~/ 60} דקות',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // תוכן התרגיל
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildExerciseContent(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // כפתור שליחה
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'סיים תרגיל',
                        action: 'complete_exercise',
                        onPressed: () => _submitExercise(trainingProvider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseContent() {
    switch (_exercise!.type) {
      case 'questionnaire':
        return _buildQuestionnaire();
      case 'action_plan':
        return _buildActionPlan();
      case 'video_reflection':
        return _buildVideoReflection();
      default:
        return const Text('סוג תרגיל לא מוכר');
    }
  }

  Widget _buildQuestionnaire() {
    final questions = _exercise!.content['questions'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((question) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildQuestion(question),
        );
      }).toList(),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'text_area':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            AppFormField(
              controller: _controllers[question['id']]!,
              textHint: question['placeholder'] ?? '',
              isTextArea: true,
              minLines: 5,
            ),
          ],
        );

      case 'multiple_choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...List<Widget>.from((question['options'] as List).map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _answers[question['id']],
                onChanged: (value) {
                  setState(() {
                    _answers[question['id']] = value;
                  });
                },
              );
            })),
          ],
        );

      case 'scale':
        final scale = question['scale'];
        final currentValue = _answers[question['id']] ?? scale['min'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(scale['labels']['${scale['min']}'] ?? '${scale['min']}'),
                Expanded(
                  child: Slider(
                    value: currentValue.toDouble(),
                    min: scale['min'].toDouble(),
                    max: scale['max'].toDouble(),
                    divisions: scale['max'] - scale['min'],
                    label: currentValue.toString(),
                    onChanged: (value) {
                      setState(() {
                        _answers[question['id']] = value.toInt();
                      });
                    },
                  ),
                ),
                Text(scale['labels']['${scale['max']}'] ?? '${scale['max']}'),
              ],
            ),
            Center(
              child: Text(
                currentValue.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  Widget _buildActionPlan() {
    final fields = _exercise!.content['fields'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field['label'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              AppFormField(
                controller: _controllers[field['name']]!,
                textHint: field['placeholder'] ?? '',
                isTextArea: field['type'] == 'text_area',
                minLines: field['type'] == 'text_area' ? 5 : 1,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoReflection() {
    final instructions = _exercise!.content['instructions'] as List;
    final reflectionQuestion =
        _exercise!.content['reflectionQuestion'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'הוראות:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...instructions.map((instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),
        Text(
          reflectionQuestion,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        AppFormField(
          controller: _controllers['reflection'] ??= TextEditingController(),
          textHint: 'שתף את המחשבות שלך...',
          isTextArea: true,
          minLines: 5,
        ),
      ],
    );
  }

  IconData _getExerciseIcon(String type) {
    switch (type) {
      case 'questionnaire':
        return Icons.quiz;
      case 'action_plan':
        return Icons.assignment;
      case 'video_reflection':
        return Icons.video_library;
      default:
        return Icons.fitness_center;
    }
  }
}
