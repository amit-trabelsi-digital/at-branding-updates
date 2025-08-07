import 'dart:convert';
import 'package:color_simp/color_simp.dart';
import 'package:http/http.dart' as http;
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';
// import 'package:mental_coach_flutter_firebase/constants.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/models/training_models.dart'
    as training;
import 'package:firebase_auth/firebase_auth.dart';

// API base URL

Future<AppUser> signup(AppUser user) async {
  final url = Uri.parse('${EnvironmentConfig.instance.serverURL}/auth/signup');

  print(url);
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    "${error['message']}".red.log();
    throw Exception(error['message'] ?? 'Signup failed');
  }

  final responseData = jsonDecode(response.body);
  return AppUser.fromJson(responseData);
}

Future<AppUser> generalLogin(AppUser user) async {
  final url =
      Uri.parse('${EnvironmentConfig.instance.serverURL}/auth/general-login');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(user.toJson()),
  );

  if (response.statusCode != 200) {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Signup failed');
  }

  final responseData = jsonDecode(response.body);
  return AppUser.fromJson(responseData);
}
// firstName: responseData['firstName'],
// email: responseData['email'],
// password: '', // Avoid returning the password

class AppFetch {
  /// Fetch function to make HTTP requests with Firebase token
  static Future<http.Response> fetch(
    String pathname, {
    String method = 'GET',
    Map<String, String>? headers,
    dynamic body,
    bool useDefaultContentType = true,
  }) async {
    try {
      // Get Firebase token
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) {
        throw Exception("User is not authenticated");
      }

      // Build headers
      final Map<String, String> requestHeaders = {
        if (useDefaultContentType) 'Content-Type': 'application/json',
        'Authorization': token,
        ...?headers,
      };

      final url = Uri.parse('${EnvironmentConfig.instance.serverURL}$pathname');
      print(url);
      // Make the HTTP request

      "before get fetch request".blue.log();
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(url,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(url,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(url,
              headers: requestHeaders, body: jsonEncode(body));
          break;
        default: // Default to GET
          response = await http.get(url, headers: requestHeaders);
          break;
      }

      return response;
    } catch (e) {
      // Log the error using the existing color logging
      "HTTP Request Error: $e".red.log();
      // Throw a more descriptive exception with request details
      throw Exception("Failed to execute $method request to $pathname: $e");
    }
  }
}

Future<AppUser> authLogin() async {
  try {
    "Fetching user data - app fetch".blue.log();
    final response = await AppFetch.fetch('/auth/login', method: 'GET');
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    if (responseData['needRefreshToken'] == true) {
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    }
    return AppUser.fromJson(responseData);
  } catch (e) {
    "Error parsing user data - app fetch: $e".red.log();
    print(StackTrace.current);
    throw Exception(e);
  }
}

class ApiService {
  Future<void> trackUserActivity(String userId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.instance.serverURL}/track-activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('Activity tracked successfully');
      } else {
        print('Failed to track activity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

// class ApiService {
//   static const String baseUrl = 'http://localhost:3000';
//   final String userId = "user123"; // Replace with actual user ID
//   List<Map<String, dynamic>> _activityBuffer = [];
//   Timer? _timer;

//   ApiService() {
//     // Send batched activities every 10 seconds
//     _timer = Timer.periodic(Duration(seconds: 10), (_) => _sendBatchedActivities());
//   }

//   void trackActivity(String action) {
//     _activityBuffer.add({
//       'action': action,
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//   }

//   Future<void> _sendBatchedActivities() async {
//     if (_activityBuffer.isEmpty) return;

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/track-activity-batch'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'userId': userId,
//           'activities': _activityBuffer,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Batch sent successfully');
//         _activityBuffer.clear(); // Clear buffer after success
//       } else {
//         print('Failed to send batch: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

//   // Call this when the app closes or user logs out
//   void dispose() {
//     _sendBatchedActivities(); // Send remaining activities
//     _timer?.cancel();
//   }
// }

class TrainingApiService {
  /// Get all training programs
  static Future<List<training.TrainingProgram>> getTrainingPrograms() async {
    try {
      final response = await AppFetch.fetch('/training-programs');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> programsData = data['data']['programs'];
        return programsData
            .map((json) => training.TrainingProgram.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch training programs: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching training programs: $e".red.log();
      throw Exception('Failed to fetch training programs: $e');
    }
  }

  /// Get specific training program
  static Future<training.TrainingProgram> getTrainingProgram(
      String programId) async {
    try {
      final response = await AppFetch.fetch('/training-programs/$programId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // בדיקה אם הנתונים נמצאים תחת 'data.program' או ישירות ב-response
        Map<String, dynamic> programData;
        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('program')) {
          programData = responseData['data']['program'];
        } else if (responseData.containsKey('program')) {
          programData = responseData['program'];
        } else {
          programData = responseData;
        }

        return training.TrainingProgram.fromJson(programData);
      } else {
        throw Exception(
            'Failed to fetch training program: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching training program: $e".red.log();
      throw Exception('Failed to fetch training program: $e');
    }
  }

  /// Get lessons for a training program
  static Future<List<training.Lesson>> getTrainingProgramLessons(
      String programId) async {
    try {
      final response =
          await AppFetch.fetch('/training-programs/$programId/lessons');
      print('Response from /training-programs/$programId/lessons: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // בדיקה אם הנתונים נמצאים תחת 'data.lessons' או ישירות ב-response
        List<dynamic> lessonsData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'].containsKey('lessons')) {
            lessonsData = responseData['data']['lessons'];
          } else if (responseData.containsKey('lessons')) {
            lessonsData = responseData['lessons'];
          } else {
            throw Exception('Unexpected response structure for lessons');
          }
        } else if (responseData is List) {
          lessonsData = responseData;
        } else {
          throw Exception('Unexpected response structure for lessons');
        }

        final lessons =
            lessonsData.map((json) => training.Lesson.fromJson(json)).toList();
        return lessons;
      } else if (response.statusCode == 403) {
        // Access denied - user might need to enroll first
        return [];
      } else {
        throw Exception('Failed to fetch lessons: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching lessons: $e".red.log();
      return [];
    }
  }

  /// Get specific lesson
  static Future<training.Lesson?> getLesson(String lessonId) async {
    try {
      print('Loading lesson with ID: $lessonId');
      final response = await AppFetch.fetch('/lessons/$lessonId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Full API response: $responseData');

        // בדיקה איפה נמצאים הנתונים
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          print('Lesson data: $data');

          // אם יש lesson בתוך data
          if (data is Map && data.containsKey('lesson')) {
            return training.Lesson.fromJson(
                data['lesson'] as Map<String, dynamic>);
          }
          // אם data הוא השיעור עצמו
          else if (data is Map) {
            return training.Lesson.fromJson(Map<String, dynamic>.from(data));
          }
        }
        // אם הנתונים ישירות ב-response
        else if (responseData.containsKey('_id') ||
            responseData.containsKey('id')) {
          return training.Lesson.fromJson(responseData);
        }

        print('Could not find lesson data in response');
        return null;
      } else {
        throw Exception('Failed to fetch lesson: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching lesson: $e".red.log();
      print('Error in getLesson: $e');
      return null;
    }
  }

  /// Get exercises for a lesson
  static Future<List<training.Exercise>> getLessonExercises(
      String lessonId) async {
    try {
      final response = await AppFetch.fetch('/lessons/$lessonId/exercises');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // בדיקה אם הנתונים נמצאים תחת 'data.exercises'
        List<dynamic> exercisesData;
        if (responseData.containsKey('data') &&
            responseData['data'].containsKey('exercises')) {
          exercisesData = responseData['data']['exercises'];
        } else if (responseData.containsKey('exercises')) {
          exercisesData = responseData['exercises'];
        } else {
          // אם התשובה היא מערך ישירות - נצטרך לדקוד מחדש
          final directData = jsonDecode(response.body);
          if (directData is List) {
            exercisesData = directData;
          } else {
            throw Exception('Unexpected response structure for exercises');
          }
        }

        return exercisesData
            .map((json) => training.Exercise.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch exercises: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching exercises: $e".red.log();
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  /// Get user training progress
  static Future<Map<String, dynamic>> getUserTrainingProgress() async {
    try {
      final response = await AppFetch.fetch('/user/training-progress');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch user progress: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching user progress: $e".red.log();
      throw Exception('Failed to fetch user progress: $e');
    }
  }

  /// Get user progress for specific program
  static Future<Map<String, dynamic>> getUserProgramProgress(
      String programId) async {
    try {
      final response =
          await AppFetch.fetch('/user/training-progress/$programId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch program progress: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching program progress: $e".red.log();
      throw Exception('Failed to fetch program progress: $e');
    }
  }

  /// Enroll user in training program
  static Future<void> enrollInProgram(String programId) async {
    try {
      final response =
          await AppFetch.fetch('/user/enroll/$programId', method: 'POST');

      if (response.statusCode != 200) {
        throw Exception('Failed to enroll in program: ${response.statusCode}');
      }
    } catch (e) {
      "Error enrolling in program: $e".red.log();
      throw Exception('Failed to enroll in program: $e');
    }
  }

  /// Start lesson
  static Future<void> startLesson(String lessonId) async {
    try {
      final response = await AppFetch.fetch('/lessons/$lessonId/start');

      if (response.statusCode != 200) {
        throw Exception('Failed to start lesson: ${response.statusCode}');
      }
    } catch (e) {
      "Error starting lesson: $e".red.log();
      throw Exception('Failed to start lesson: $e');
    }
  }

  /// Update lesson progress
  static Future<void> updateLessonProgress(
      String lessonId, Map<String, dynamic> progressData) async {
    try {
      final response = await AppFetch.fetch('/lessons/$lessonId/progress',
          method: 'PUT', body: progressData);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update lesson progress: ${response.statusCode}');
      }
    } catch (e) {
      "Error updating lesson progress: $e".red.log();
      throw Exception('Failed to update lesson progress: $e');
    }
  }

  /// Submit exercise response
  static Future<void> submitExerciseResponse(
      String exerciseId, Map<String, dynamic> responseData) async {
    try {
      final response = await AppFetch.fetch('/exercises/$exerciseId/submit',
          method: 'POST', body: responseData);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to submit exercise response: ${response.statusCode}');
      }
    } catch (e) {
      "Error submitting exercise response: $e".red.log();
      throw Exception('Failed to submit exercise response: $e');
    }
  }

  /// Get next lesson for program
  static Future<training.Lesson?> getNextLesson(String programId) async {
    try {
      final response = await AppFetch.fetch('/user/next-lesson/$programId');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['lesson'] != null) {
          return training.Lesson.fromJson(data['lesson']);
        }
        return null;
      } else {
        throw Exception('Failed to fetch next lesson: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching next lesson: $e".red.log();
      throw Exception('Failed to fetch next lesson: $e');
    }
  }

  /// Get all user exercise responses
  static Future<List<Map<String, dynamic>>> getUserExerciseResponses() async {
    try {
      final response = await AppFetch.fetch('/user/exercise-responses');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']['responses'] ?? []);
      } else {
        throw Exception(
            'Failed to fetch exercise responses: ${response.statusCode}');
      }
    } catch (e) {
      "Error fetching exercise responses: $e".red.log();
      throw Exception('Failed to fetch exercise responses: $e');
    }
  }
}

// פונקציה לקבלת גרסת ה-API
Future<Map<String, dynamic>> getApiVersion() async {
  try {
    final url = Uri.parse('${EnvironmentConfig.instance.serverURL}/info/version');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['data'];
      }
    }
    return {'version': 'unknown', 'name': 'unknown'};
  } catch (e) {
    "Error fetching API version: $e".red.log();
    return {'version': 'unknown', 'name': 'unknown'};
  }
}
