import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

class OtpService {
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Store phone number during the flow
  String? _currentPhoneNumber;
  String? _currentEmail;
  
  /// Format Israeli phone number to E.164
  String formatPhoneNumber(String phone) {
    // Remove all non-numeric characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Handle Israeli numbers
    if (cleaned.startsWith('0')) {
      cleaned = '972' + cleaned.substring(1);
    }
    
    // Add + if not present
    if (!cleaned.startsWith('+')) {
      cleaned = '+' + cleaned;
    }
    
    return cleaned;
  }
  
  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
    String? email,
  }) async {
    try {
      _currentPhoneNumber = formatPhoneNumber(phoneNumber);
      _currentEmail = email;
      
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.instance.serverURL.replaceAll('/api', '')}/api/otp/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': _currentPhoneNumber,
          'email': email,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (kDebugMode && data['code'] != null) {
          print('🔐 Development Mode - OTP Code: ${data['code']}');
        }
        return {
          'success': true,
          'message': data['message'] ?? 'קוד נשלח בהצלחה',
          'phoneNumber': data['phoneNumber'],
          'devCode': kDebugMode ? data['code'] : null,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'שגיאה בשליחת קוד',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return {
        'success': false,
        'message': 'שגיאה בחיבור לשרת',
        'error': e.toString(),
      };
    }
  }
  
  /// Verify OTP code
  Future<Map<String, dynamic>> verifyOTP({
    required String code,
  }) async {
    try {
      if (_currentPhoneNumber == null) {
        return {
          'success': false,
          'message': 'לא נמצא מספר טלפון',
        };
      }
      
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.instance.serverURL.replaceAll('/api', '')}/api/otp/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': _currentPhoneNumber,
          'code': code,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      print('OTP Verify Response: ${response.statusCode}');
      print('Response data keys: ${data.keys.toList()}');
      print('Has customToken: ${data['customToken'] != null}');
      print('Has token: ${data['token'] != null}');
      
      if (response.statusCode == 200 && (data['customToken'] != null || data['token'] != null)) {
        // Sign in with Firebase custom token
        try {
          final token = data['customToken'] ?? data['token'];
          print('Using token for Firebase sign in...');
          final credential = await _auth.signInWithCustomToken(token);
          print('Firebase sign in successful! User: ${credential.user?.uid}');
          
          return {
            'success': true,
            'message': 'התחברת בהצלחה!',
            'user': credential.user,
            'userData': data['user'],
          };
        } catch (firebaseError) {
          print('Firebase sign in error: $firebaseError');
          return {
            'success': false,
            'message': 'שגיאה בהתחברות למערכת',
            'error': firebaseError.toString(),
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'קוד שגוי',
          'error': data['error'],
          'remainingAttempts': data['remainingAttempts'],
        };
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'שגיאה בחיבור לשרת',
        'error': e.toString(),
      };
    }
  }
  
  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP() async {
    if (_currentPhoneNumber == null) {
      return {
        'success': false,
        'message': 'לא נמצא מספר טלפון',
      };
    }
    
    return await sendOTP(
      phoneNumber: _currentPhoneNumber!,
      email: _currentEmail,
    );
  }
  
  /// Check OTP service status
  Future<Map<String, dynamic>> checkServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.instance.serverURL.replaceAll('/api', '')}/api/otp/status'),
      );
      
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Cannot connect to OTP service',
      };
    }
  }
  
  /// Clear current session
  void clearSession() {
    _currentPhoneNumber = null;
    _currentEmail = null;
  }
}