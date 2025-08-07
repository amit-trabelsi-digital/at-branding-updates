import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// מחלקה לניהול גרסאות אפליקציה
class VersionHelper {
  static VersionHelper? _instance;
  static VersionHelper get instance => _instance ??= VersionHelper._();
  
  VersionHelper._();
  
  // נתונים מקובץ version.json
  String _version = '0.9.0';
  String _build = '2025.08.06.013';
  String _buildNumber = '13';
  String _buildDate = '';
  String _appName = 'Mental Coach Flutter';
  String _description = 'Mental Coach Flutter App - Player Training Platform';
  
  // נתונים מ-package_info_plus
  String _appVersion = '';
  String _packageName = '';
  
  bool _isInitialized = false;
  
  /// אתחול המחלקה - קריאה נדרשת בהתחלת האפליקציה
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // קריאת נתונים מ-package_info_plus
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _packageName = packageInfo.packageName;
      
      // ניסיון לקרוא מקובץ version.json (אם קיים)
      await _loadVersionFromJson();
      
      _isInitialized = true;
    } catch (e) {
      print('שגיאה באתחול VersionHelper: $e');
      _isInitialized = true; // נמשיך עם ברירות המחדל
    }
  }
  
  /// קריאת נתונים מקובץ version.json
  Future<void> _loadVersionFromJson() async {
    try {
      final String versionJson = await rootBundle.loadString('version.json');
      final Map<String, dynamic> versionData = json.decode(versionJson);
      
      _version = versionData['version'] ?? _version;
      _build = versionData['build'] ?? _build;
      _buildNumber = versionData['buildNumber']?.toString() ?? _buildNumber;
      _buildDate = versionData['buildDate'] ?? _buildDate;
      _appName = versionData['name'] ?? _appName;
      _description = versionData['description'] ?? _description;
      
      print('✅ נתוני גרסה נטענו מversion.json');
    } catch (e) {
      print('⚠️ לא ניתן לטעון version.json, משתמש בברירת מחדל: $e');
    }
  }
  
  // Getters לנתוני גרסה
  
  /// גרסת האפליקציה (מפורמט Semantic Versioning)
  String get version => _version;
  
  /// מספר Build מפורמט
  String get build => _build;
  
  /// מספר Build פשוט (למשימות Flutter)
  String get buildNumber => _buildNumber;
  
  /// תאריך Build
  String get buildDate => _buildDate;
  
  /// שם האפליקציה
  String get appName => _appName;
  
  /// תיאור האפליקציה
  String get description => _description;
  
  /// גרסה מ-PackageInfo (pubspec.yaml)
  String get packageVersion => _appVersion;
  
  /// שם החבילה
  String get packageName => _packageName;
  
  /// גרסה מלאה עם Build Number (לתצוגה למשתמש)
  String get fullVersion => '$_version+$_buildNumber';
  
  /// מידע מלא על הגרסה
  Map<String, String> get versionInfo => {
    'version': _version,
    'build': _build,
    'buildNumber': _buildNumber,
    'buildDate': _buildDate,
    'appName': _appName,
    'description': _description,
    'packageVersion': _appVersion,
    'packageName': _packageName,
    'fullVersion': fullVersion,
  };
  
  /// בדיקה אם הגרסה אותחלה
  bool get isInitialized => _isInitialized;
  
  /// פורמט גרסה לתצוגה בממשק
  String getDisplayVersion({bool showBuild = false, bool showDate = false}) {
    String display = 'גרסה $_version';
    
    if (showBuild) {
      display += ' (build $_buildNumber)';
    }
    
    if (showDate && _buildDate.isNotEmpty) {
      final DateTime? date = DateTime.tryParse(_buildDate);
      if (date != null) {
        display += ' - ${date.day}/${date.month}/${date.year}';
      }
    }
    
    return display;
  }
  
  /// השוואת גרסאות
  bool isNewerThan(String otherVersion) {
    try {
      final currentParts = _version.split('.').map(int.parse).toList();
      final otherParts = otherVersion.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        final current = i < currentParts.length ? currentParts[i] : 0;
        final other = i < otherParts.length ? otherParts[i] : 0;
        
        if (current > other) return true;
        if (current < other) return false;
      }
      
      return false; // שווות
    } catch (e) {
      return false;
    }
  }
}