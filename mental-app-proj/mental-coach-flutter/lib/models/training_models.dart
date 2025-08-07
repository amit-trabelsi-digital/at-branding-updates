// מודלים עבור מערכת הקורסים והאימונים

class TrainingProgram {
  final String id;
  final String title;
  final String description;
  final String? instructor;
  final String category;
  final String type;
  final String difficulty;
  final int totalLessons;
  final int estimatedDuration;
  final AccessRules? accessRules;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainingProgram({
    required this.id,
    required this.title,
    required this.description,
    this.instructor,
    required this.category,
    required this.type,
    required this.difficulty,
    required this.totalLessons,
    required this.estimatedDuration,
    this.accessRules,
    required this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    try {
      return TrainingProgram(
        id: json['_id'] ?? json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        instructor: json['instructor'],
        category: json['category'] ?? '',
        type: json['type'] ?? '',
        difficulty: json['difficulty'] ?? '',
        totalLessons: json['totalLessons'] ?? json['totallessons'] ?? 0,
        estimatedDuration: json['estimatedDuration'] ?? 0,
        accessRules: json['accessRules'] != null
            ? AccessRules.fromJson(json['accessRules'])
            : null,
        isPublished: json['isPublished'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
    } catch (e) {
      print('Error in TrainingProgram.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class Lesson {
  final String id;
  final String? trainingProgramId;
  final int lessonNumber;
  final String title;
  final String? shortTitle;
  final String? description;
  final LessonContent? content;
  final LessonMedia? media;
  final int order;
  final int duration;
  final AccessRules? accessRules;
  final ContentStatus contentStatus;
  final Scoring? scoring;
  final bool? hasAccess;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    this.trainingProgramId,
    required this.lessonNumber,
    required this.title,
    this.shortTitle,
    this.description,
    this.content,
    this.media,
    required this.order,
    required this.duration,
    this.accessRules,
    required this.contentStatus,
    this.scoring,
    this.hasAccess,
    this.createdAt,
    this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    try {
      // טיפול ב-trainingProgramId שיכול להיות string או object
      String? programId;
      if (json['trainingProgramId'] != null) {
        if (json['trainingProgramId'] is String) {
          programId = json['trainingProgramId'];
        } else if (json['trainingProgramId'] is Map) {
          programId = json['trainingProgramId']['_id'] ??
              json['trainingProgramId']['id'];
        }
      }

      return Lesson(
        id: json['_id'] ?? json['id'],
        trainingProgramId: programId,
        lessonNumber: json['lessonNumber'] ?? 0,
        title: json['title'] ?? '',
        shortTitle: json['shortTitle'],
        description: json['description'],
        content: json['content'] != null
            ? LessonContent.fromJson(json['content'])
            : null,
        media:
            json['media'] != null ? LessonMedia.fromJson(json['media']) : null,
        order: json['order'] ?? 0,
        duration: json['duration'] ?? 0,
        accessRules: json['accessRules'] != null
            ? AccessRules.fromJson(json['accessRules'])
            : null,
        contentStatus: ContentStatus.fromJson(json['contentStatus'] ?? {}),
        scoring:
            json['scoring'] != null ? Scoring.fromJson(json['scoring']) : null,
        hasAccess: json['hasAccess'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
      );
    } catch (e, stackTrace) {
      print('Error in Lesson.fromJson: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class LessonContent {
  final String primaryContent;
  final String additionalContent;
  final String structure;
  final String notes;
  final List<String> highlights;

  LessonContent({
    required this.primaryContent,
    required this.additionalContent,
    required this.structure,
    required this.notes,
    required this.highlights,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      primaryContent: json['primaryContent'] ?? '',
      additionalContent: json['additionalContent'] ?? '',
      structure: json['structure'] ?? '',
      notes: json['notes'] ?? '',
      highlights: json['highlights'] != null
          ? List<String>.from(json['highlights'])
          : [],
    );
  }
}

class LessonMedia {
  final String? videoUrl;
  final String? videoType;
  final double videoDuration;
  final List<AudioFile> audioFiles;
  final List<Document> documents;

  LessonMedia({
    this.videoUrl,
    this.videoType,
    required this.videoDuration,
    required this.audioFiles,
    required this.documents,
  });

  factory LessonMedia.fromJson(Map<String, dynamic> json) {
    return LessonMedia(
      videoUrl: json['videoUrl'],
      videoType: json['videoType'],
      videoDuration: (json['videoDuration'] ?? 0).toDouble(),
      audioFiles: (json['audioFiles'] as List? ?? [])
          .map((e) => AudioFile.fromJson(e))
          .toList(),
      documents: (json['documents'] as List? ?? [])
          .map((e) => Document.fromJson(e))
          .toList(),
    );
  }
}

class AudioFile {
  final String name;
  final String url;
  final int duration;
  final String? id;

  AudioFile({
    required this.name,
    required this.url,
    required this.duration,
    this.id,
  });

  factory AudioFile.fromJson(Map<String, dynamic> json) {
    return AudioFile(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      duration: json['duration'] ?? 0,
      id: json['id'] ?? json['_id'],
    );
  }
}

class Document {
  final String name;
  final String url;
  final String type;

  Document({
    required this.name,
    required this.url,
    required this.type,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class AccessRules {
  final List<String> subscriptionTypes;
  final List<String>? specificUsers;
  final List<String>? prerequisites;
  final bool? requireSequential;
  final UnlockConditions? unlockConditions;

  AccessRules({
    required this.subscriptionTypes,
    this.specificUsers,
    this.prerequisites,
    this.requireSequential,
    this.unlockConditions,
  });

  factory AccessRules.fromJson(Map<String, dynamic> json) {
    return AccessRules(
      subscriptionTypes: List<String>.from(json['subscriptionTypes'] ?? []),
      specificUsers: json['specificUsers'] != null
          ? List<String>.from(json['specificUsers'])
          : null,
      prerequisites: json['prerequisites'] != null
          ? List<String>.from(json['prerequisites'])
          : null,
      requireSequential: json['requireSequential'],
      unlockConditions: json['unlockConditions'] != null
          ? UnlockConditions.fromJson(json['unlockConditions'])
          : null,
    );
  }
}

class UnlockConditions {
  final bool requirePreviousCompletion;
  final int minimumProgressPercentage;

  UnlockConditions({
    required this.requirePreviousCompletion,
    required this.minimumProgressPercentage,
  });

  factory UnlockConditions.fromJson(Map<String, dynamic> json) {
    return UnlockConditions(
      requirePreviousCompletion: json['requirePreviousCompletion'] ?? false,
      minimumProgressPercentage: json['minimumProgressPercentage'] ?? 0,
    );
  }
}

class ContentStatus {
  final bool isPublished;
  final bool isVisible;
  final bool isLocked;

  ContentStatus({
    required this.isPublished,
    required this.isVisible,
    required this.isLocked,
  });

  factory ContentStatus.fromJson(Map<String, dynamic> json) {
    return ContentStatus(
      isPublished: json['isPublished'] ?? false,
      isVisible: json['isVisible'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }
}

class Scoring {
  final int passingScore;
  final int maxScore;
  final int minimumCompletionTime;
  final int? points;
  final int? bonusPoints;
  final List<String>? scoreableActions;

  Scoring({
    required this.passingScore,
    required this.maxScore,
    required this.minimumCompletionTime,
    this.points,
    this.bonusPoints,
    this.scoreableActions,
  });

  int get totalPoints => points ?? maxScore;

  factory Scoring.fromJson(Map<String, dynamic> json) {
    return Scoring(
      passingScore: json['passingScore'] ?? 0,
      maxScore: json['maxScore'] ?? json['points'] ?? 100,
      minimumCompletionTime: json['minimumCompletionTime'] ?? 0,
      points: json['points'],
      bonusPoints: json['bonusPoints'],
      scoreableActions: json['scoreableActions'] != null
          ? List<String>.from(json['scoreableActions'])
          : null,
    );
  }
}

class Exercise {
  final String id;
  final String lessonId;
  final String exerciseId;
  final String type;
  final String title;
  final String description;
  final ExerciseSettings settings;
  final Map<String, dynamic> content;
  final ExerciseAccessibility accessibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.lessonId,
    required this.exerciseId,
    required this.type,
    required this.title,
    required this.description,
    required this.settings,
    required this.content,
    required this.accessibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'],
      lessonId: json['lessonId'],
      exerciseId: json['exerciseId'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      settings: ExerciseSettings.fromJson(json['settings']),
      content: json['content'],
      accessibility: ExerciseAccessibility.fromJson(json['accessibility']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ExerciseSettings {
  final int timeLimit;
  final bool required;
  final int points;
  final int order;

  ExerciseSettings({
    required this.timeLimit,
    required this.required,
    required this.points,
    required this.order,
  });

  factory ExerciseSettings.fromJson(Map<String, dynamic> json) {
    return ExerciseSettings(
      timeLimit: json['timeLimit'] ?? 0,
      required: json['required'] ?? false,
      points: json['points'] ?? 0,
      order: json['order'] ?? 0,
    );
  }
}

class ExerciseAccessibility {
  final bool hasAudioInstructions;
  final bool supportsDyslexia;
  final bool hasAlternativeFormat;

  ExerciseAccessibility({
    required this.hasAudioInstructions,
    required this.supportsDyslexia,
    required this.hasAlternativeFormat,
  });

  factory ExerciseAccessibility.fromJson(Map<String, dynamic> json) {
    return ExerciseAccessibility(
      hasAudioInstructions: json['hasAudioInstructions'] ?? false,
      supportsDyslexia: json['supportsDyslexia'] ?? false,
      hasAlternativeFormat: json['hasAlternativeFormat'] ?? false,
    );
  }
}

// מודל להתקדמות המשתמש
class UserProgress {
  final String userId;
  final String lessonId;
  final bool isCompleted;
  final int progressPercentage;
  final DateTime? completedAt;
  final Map<String, dynamic>? exerciseResults;

  UserProgress({
    required this.userId,
    required this.lessonId,
    required this.isCompleted,
    required this.progressPercentage,
    this.completedAt,
    this.exerciseResults,
  });
}
