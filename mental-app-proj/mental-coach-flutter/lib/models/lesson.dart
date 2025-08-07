// מודל לשיעור אימון
class Lesson {
  final String id;
  final String title;
  final String description;
  final LessonMedia media;
  final int duration; // בדקות
  final String category;
  final String level;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.media,
    required this.duration,
    required this.category,
    required this.level,
    this.createdAt,
    this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      media: LessonMedia.fromJson(json['media'] ?? {}),
      duration: json['duration'] ?? 0,
      category: json['category'] ?? '',
      level: json['level'] ?? 'beginner',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'media': media.toJson(),
      'duration': duration,
      'category': category,
      'level': level,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// מודל למדיה של השיעור
class LessonMedia {
  final String? videoUrl;
  final String? audioUrl;
  final String? imageUrl;
  final String? thumbnailUrl;

  LessonMedia({
    this.videoUrl,
    this.audioUrl,
    this.imageUrl,
    this.thumbnailUrl,
  });

  factory LessonMedia.fromJson(Map<String, dynamic> json) {
    return LessonMedia(
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
