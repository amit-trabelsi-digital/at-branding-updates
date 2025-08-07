import 'dart:io';
import 'package:color_simp/color_simp.dart';
import 'package:flutter/foundation.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SupportService {
  /// שליחת פנייה לתמיכה
  static Future<bool> sendSupportRequest({
    required String subject,
    required String description,
    required String userEmail,
    required String userName,
    required String currentPage,
    String? openDialog,
    List<String>? attachments,
  }) async {
    try {
      // איסוף מידע על הסביבה
      final deviceInfo = DeviceInfoPlugin();
      String userAgent = '';
      String hostname = '';
      String environment = 'production';

      // קבלת מידע על הגרסה
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      if (kIsWeb) {
        // מידע עבור Web
        final webInfo = await deviceInfo.webBrowserInfo;
        userAgent = webInfo.userAgent ?? 'Web Browser';
        hostname = Uri.base.host;
        
        // קביעת סביבה לפי ה-hostname
        if (hostname.contains('localhost') || hostname.contains('127.0.0.1')) {
          environment = 'development';
        } else if (hostname.contains('dev-') || hostname.contains('test')) {
          environment = 'test';
        }
      } else if (Platform.isAndroid) {
        // מידע עבור Android
        final androidInfo = await deviceInfo.androidInfo;
        userAgent = 'Android ${androidInfo.version.release} (${androidInfo.model})';
        hostname = 'Android App';
      } else if (Platform.isIOS) {
        // מידע עבור iOS
        final iosInfo = await deviceInfo.iosInfo;
        userAgent = 'iOS ${iosInfo.systemVersion} (${iosInfo.model})';
        hostname = 'iOS App';
      }

      // הוספת גרסת האפליקציה ל-userAgent
      userAgent += ' | App v$appVersion ($buildNumber)';

      // הכנת הנתונים לשליחה
      final supportData = {
        'subject': subject,
        'description': description,
        'userEmail': userEmail,
        'userName': userName,
        'currentPage': currentPage,
        'dateTime': DateTime.now().toIso8601String(),
        'attachments': attachments ?? [],
        'openDialog': openDialog,
        'environment': environment,
        'hostname': hostname,
        'userAgent': userAgent,
      };

      "Sending support request...".yellow.log();
      
      // שליחת הבקשה
      final response = await AppFetch.fetch(
        '/support',
        method: 'POST',
        body: supportData,
      );

      if (response.statusCode == 200) {
        "Support request sent successfully".green.log();
        return true;
      } else {
        "Failed to send support request: ${response.statusCode}".red.log();
        "Response: ${response.body}".red.log();
        return false;
      }
    } catch (e) {
      "Error sending support request: $e".red.log();
      return false;
    }
  }

  /// המרת שם מסך לעברית
  static String getPageNameInHebrew(String routeName) {
    final pageNames = {
      '/': 'דף הבית',
      '/login': 'כניסה',
      '/dashboard': 'דשבורד',
      '/profile': 'פרופיל שחקן',
      '/cases-and-reactions': 'מקרים ותגובות',
      '/training-plan': 'תוכנית אימון',
      '/mental-profile': 'הפרופיל המנטלי שלי',
      '/set-profile': 'עריכת פרופיל',
      '/set-goals-profile': 'עריכת יעדים',
      '/goals': 'יעדים',
      '/training': 'אימון',
      '/match': 'משחק',
    };

    return pageNames[routeName] ?? routeName;
  }
}