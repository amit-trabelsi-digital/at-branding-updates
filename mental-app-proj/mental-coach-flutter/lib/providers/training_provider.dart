import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mental_coach_flutter_firebase/models/training_models.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';

class TrainingProvider with ChangeNotifier {
  final List<Lesson> _userProgress = [];
  TrainingProgram? _currentProgram;
  List<TrainingProgram> _programs = [];
  List<Lesson> _lessons = [];
  final List<Exercise> _exercises = [];

  // נתוני דמה למעקב אחרי התקדמות
  final Map<String, bool> _completedLessons = {};
  final Map<String, int> _lessonProgress = {};

  // מצב טעינה
  bool _isLoading = false;
  String? _error;

  TrainingProgram? get currentProgram => _currentProgram;
  List<TrainingProgram> get programs => _programs;
  List<Lesson> get lessons => _lessons;
  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// טעינת כל תוכניות האימון
  Future<void> loadTrainingPrograms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _programs = await TrainingApiService.getTrainingPrograms();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// טעינת תוכנית אימון ספציפית
  Future<void> loadTrainingProgram(String programId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Loading training program with ID: $programId');

    try {
      _currentProgram = await TrainingApiService.getTrainingProgram(programId);

      // ניסיון לטעון שיעורים
      await loadLessonsForProgram(programId);

      // אם אין שיעורים, אולי צריך להירשם לתוכנית
      if (_lessons.isEmpty) {
        print('No lessons found, trying to enroll in program...');
        try {
          await TrainingApiService.enrollInProgram(programId);
          print('Successfully enrolled, trying to load lessons again...');
          await loadLessonsForProgram(programId);
        } catch (enrollError) {
          print('Failed to enroll: $enrollError');
          // ממשיכים גם אם ההרשמה נכשלה
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// טעינת שיעורים לתוכנית אימון
  Future<void> loadLessonsForProgram(String programId) async {
    try {
      // ניקוי שגיאות קודמות
      _error = null;

      _lessons = await TrainingApiService.getTrainingProgramLessons(programId);
      _lessons.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// טעינת שיעור ספציפי
  Future<Lesson?> loadLesson(String lessonId) async {
    try {
      print('Loading lesson with ID: $lessonId');
      final lesson = await TrainingApiService.getLesson(lessonId);
      if (lesson != null) {
        print('Lesson loaded successfully: ${lesson.title}');
      } else {
        print('Lesson is null');
      }
      return lesson;
    } catch (e) {
      print('Error in loadLesson: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// טעינת תרגילים לשיעור
  Future<void> loadExercisesForLesson(String lessonId) async {
    try {
      final exercises = await TrainingApiService.getLessonExercises(lessonId);
      _exercises.clear();
      _exercises.addAll(exercises);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// הרשמה לתוכנית אימון
  Future<bool> enrollInProgram(String programId) async {
    try {
      await TrainingApiService.enrollInProgram(programId);
      await loadTrainingProgram(programId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// התחלת שיעור
  Future<bool> startLesson(String lessonId) async {
    try {
      await TrainingApiService.startLesson(lessonId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// עדכון התקדמות בשיעור
  Future<void> updateLessonProgress(String lessonId, int progress,
      {Map<String, dynamic>? additionalData}) async {
    _lessonProgress[lessonId] = progress;

    // אם הגיע ל-100%, מסמן כהושלם
    if (progress >= 100) {
      _completedLessons[lessonId] = true;
    }

    notifyListeners();

    try {
      final progressData = {
        'progress': progress,
        'completedAt':
            progress >= 100 ? DateTime.now().toIso8601String() : null,
        ...?additionalData,
      };

      await TrainingApiService.updateLessonProgress(lessonId, progressData);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// שליחת תשובה לתרגיל
  Future<bool> submitExerciseResponse(
      String exerciseId, Map<String, dynamic> responseData) async {
    try {
      await TrainingApiService.submitExerciseResponse(exerciseId, responseData);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// קבלת השיעור הבא
  Future<Lesson?> getNextLessonFromServer(String programId) async {
    try {
      return await TrainingApiService.getNextLesson(programId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void loadLessons() {
    // שמירה על תאימות לאחור - אם יש תוכנית נוכחית, נטען את השיעורים שלה
    if (_currentProgram != null) {
      loadLessonsForProgram(_currentProgram!.id);
    }
  }

  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }

  bool checkLessonCompletion(String lessonId) {
    return _userProgress.any((lesson) => lesson.id == lessonId) ||
        _completedLessons[lessonId] == true;
  }

  bool isLessonAccessible(String lessonId) {
    // TODO: בדיקה אם השיעור נגיש

    // final lesson = getLessonById(lessonId);
    // if (lesson == null) return false;

    // // בדיקה אם contentStatus קיים
    // if (lesson.contentStatus.isVisible != null && lesson.contentStatus.isLocked != null) {
    //   return lesson.contentStatus.isVisible && !lesson.contentStatus.isLocked;
    // }

    // אם אין מידע על סטטוס, מניחים שהשיעור נגיש
    return true;
  }

  // מקבל את אחוז ההתקדמות בשיעור
  int getLessonProgress(String lessonId) {
    return _lessonProgress[lessonId] ?? 0;
  }

  void markLessonAsCompleted(String lessonId) {
    final lesson = getLessonById(lessonId);
    if (lesson != null && !checkLessonCompletion(lessonId)) {
      _userProgress.add(lesson);
      _completedLessons[lessonId] = true;
      notifyListeners();

      // עדכון בשרת
      updateLessonProgress(lessonId, 100);
    }
  }

  // מקבל את השיעור הקודם
  Lesson? getPreviousLesson(Lesson currentLesson) {
    int currentIndex = _lessons.indexWhere((l) => l.id == currentLesson.id);
    if (currentIndex > 0) {
      return _lessons[currentIndex - 1];
    }
    return null;
  }

  // מקבל את השיעור הבא
  Lesson? getNextLesson(Lesson currentLesson) {
    int currentIndex = _lessons.indexWhere((l) => l.id == currentLesson.id);
    if (currentIndex < _lessons.length - 1) {
      return _lessons[currentIndex + 1];
    }
    return null;
  }

  // מקבל תרגילים לשיעור מסוים
  List<Exercise> getExercisesForLesson(String lessonId) {
    return _exercises.where((e) => e.lessonId == lessonId).toList()
      ..sort((a, b) => a.settings.order.compareTo(b.settings.order));
  }

  // מחשב את סך הנקודות שהמשתמש צבר
  int getTotalPoints() {
    int totalPoints = 0;

    for (String lessonId in _completedLessons.keys) {
      if (_completedLessons[lessonId] == true) {
        try {
          Lesson? lesson = _lessons.firstWhere((l) => l.id == lessonId);
          if (lesson.scoring != null) {
            totalPoints += lesson.scoring!.totalPoints;
          }
        } catch (e) {
          // אם לא נמצא השיעור, ממשיכים
          continue;
        }
      }
    }

    return totalPoints;
  }

  // מחשב את אחוז ההתקדמות הכללי בקורס
  double getOverallProgress() {
    if (_lessons.isEmpty) return 0.0;

    int completedCount =
        _completedLessons.values.where((v) => v == true).length;
    return (completedCount / _lessons.length) * 100;
  }

  // מקבל את השיעור הנוכחי שהמשתמש צריך להשלים
  Lesson? getCurrentLesson() {
    for (Lesson lesson in _lessons) {
      if (!checkLessonCompletion(lesson.id) && isLessonAccessible(lesson.id)) {
        return lesson;
      }
    }
    return null;
  }

  /// ניקוי שגיאות
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
