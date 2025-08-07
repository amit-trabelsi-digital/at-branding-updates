import 'package:flutter/foundation.dart';
import 'package:color_simp/color_simp.dart';

enum Environment { dev, test, prod, local, docker }

class EnvironmentConfig {
  static final EnvironmentConfig instance = EnvironmentConfig._internal();
  
  EnvironmentConfig._internal();
  
  static Environment _environment = Environment.docker;
  
  static Environment get environment => _environment;
  
  // קבלת משתני סביבה מ-Docker או ערכי ברירת מחדל
  static const String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api'
  );
  
  static const String _firebaseApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: ''
  );
  
  static const String _firebaseAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN', 
    defaultValue: ''
  );
  
  static const String _firebaseProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
    defaultValue: ''
  );
  
  static const String _firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
    defaultValue: ''
  );
  
  static const String _firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    defaultValue: ''
  );
  
  static const String _firebaseAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: ''
  );
  
  static void setEnvironment(Environment env) {
    _environment = env;
    
    // זיהוי אוטומטי של סביבת Docker
    if (kIsWeb && _apiUrl.contains('docker')) {
      _environment = Environment.docker;
    }
    
    // זיהוי אוטומטי של localhost
    if (kIsWeb) {
      final String host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        if (_environment != Environment.docker) {
          _environment = Environment.local;
        }
      }
    }
    
    "Working on ${_environment.name.toUpperCase()} server".green.log();
    "API URL: $_apiUrl".yellow.log();
  }
  
  String get serverURL {
    // שימוש במשתנה סביבה אם הוגדר
    if (_apiUrl.isNotEmpty && _apiUrl != 'http://localhost:3000/api') {
      return _apiUrl;
    }
    
    // ערכי ברירת מחדל לפי סביבה
    switch (_environment) {
      case Environment.docker:
        return _apiUrl;
      case Environment.local:
        return "http://localhost:3000/api";
      case Environment.dev:
        return "https://dev-srv.eitanazaria.co.il/api";
      case Environment.test:
        return "https://dev-srv.eitanazaria.co.il/api";
      case Environment.prod:
        return "https://app-srv.eitanazaria.co.il/api";
    }
  }
  
  // גישה להגדרות Firebase
  Map<String, String> get firebaseConfig => {
    'apiKey': _firebaseApiKey,
    'authDomain': _firebaseAuthDomain,
    'projectId': _firebaseProjectId,
    'storageBucket': _firebaseStorageBucket,
    'messagingSenderId': _firebaseMessagingSenderId,
    'appId': _firebaseAppId,
  };
  
  // בדיקה האם Firebase מוגדר
  bool get isFirebaseConfigured => 
    _firebaseApiKey.isNotEmpty && 
    _firebaseProjectId.isNotEmpty;
}