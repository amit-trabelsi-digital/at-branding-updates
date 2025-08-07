import 'package:flutter/foundation.dart';

/// מחלקת קונפיגורציה ראשית לאפליקציה
/// משלבת compile-time ו-runtime configurations
class AppConfig {
  // Compile-time constants מ-dart-define
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static const bool enableCrashlytics = bool.fromEnvironment(
    'ENABLE_CRASHLYTICS',
    defaultValue: false,
  );
  
  // Runtime getters עם fallback לערכים קיימים
  static String get serverUrl {
    // אם יש URL מ-dart-define, השתמש בו
    if (apiBaseUrl.isNotEmpty) {
      return apiBaseUrl;
    }
    
    // אחרת, השתמש בלוגיקה הקיימת
    switch (environment) {
      case 'local':
        return _getLocalUrl();
      case 'dev':
        return 'https://dev-srv.eitanazaria.co.il/api';
      case 'test':
        return 'https://dev-srv.eitanazaria.co.il/api';
      case 'prod':
        return 'https://app-srv.eitanazaria.co.il/api';
      default:
        return 'https://dev-srv.eitanazaria.co.il/api';
    }
  }
  
  static String _getLocalUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    // לאמולטורים ומכשירים פיזיים
    return 'http://10.0.2.2:3000/api'; // Android emulator
  }
  
  // בדיקות סביבה
  static bool get isDevelopment => environment == 'dev' || environment == 'local';
  static bool get isProduction => environment == 'prod';
  static bool get isTest => environment == 'test';
  static bool get isLocal => environment == 'local';
  
  // הגדרות נוספות
  static const int requestTimeout = int.fromEnvironment(
    'REQUEST_TIMEOUT',
    defaultValue: 30000,
  );
  
  static const int maxRetries = int.fromEnvironment(
    'MAX_RETRIES',
    defaultValue: 3,
  );
  
  // Debug info
  static void printConfig() {
    if (kDebugMode) {
      print('╔════════════════════════════════════════╗');
      print('║          App Configuration            ║');
      print('╠════════════════════════════════════════╣');
      print('║ Environment: $environment');
      print('║ Server URL: $serverUrl');
      print('║ Analytics: $enableAnalytics');
      print('║ Crashlytics: $enableCrashlytics');
      print('║ Timeout: ${requestTimeout}ms');
      print('║ Max Retries: $maxRetries');
      print('╚════════════════════════════════════════╝');
    }
  }
} 