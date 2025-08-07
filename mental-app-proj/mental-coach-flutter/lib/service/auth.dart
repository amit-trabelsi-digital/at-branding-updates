import 'package:color_simp/color_simp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';
import 'package:mental_coach_flutter_firebase/service/firebase_messaging_service.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  ConfirmationResult? _webConfirmationResult;
  String? _verificationId;
  RecaptchaVerifier? _recaptchaVerifier;

  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        '===== Google authentication canceled by user ====='.yellow.log();
        throw Exception('ההתחברות בוטלה');
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);

      if (context.mounted) {
        signInWithCredential(result, context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'אירעה שגיאה בהתחברות';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'חשבון זה רשום עם שיטת התחברות אחרת';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'פרטי ההתחברות אינם תקינים';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'המשתמש הזה חסום';
      }

      if (context.mounted) _showErrorMessage(context, errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      "Google auth ERR: ${e.toString()}".red.log();
      if (context.mounted) _showErrorMessage(context, 'אירעה שגיאה בהתחברות');
      rethrow;
    }
  }

  Future<void> signInWithAppleHandler(BuildContext context) async {
    final appleProvider = AppleAuthProvider();
    final credential =
        await FirebaseAuth.instance.signInWithProvider(appleProvider);

    if (context.mounted) {
      signInWithCredential(credential, context);
    }
  }

  Future<void> signInWithCredential(
      UserCredential credential, BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.checkAuthState();

      if (credential.user != null) {
        if (!context.mounted) return;

        // Initialize notification service only after successful login
        await FirebaseMessagingService.initialize();

        void navigateBasedOnUserState() {
          if (userProvider.user?.setProfileComplete == false) {
            context.go('/set-profile');
          } else if (userProvider.user?.setGoalAndProfileComplete == false) {
            context.go('/set-goals-profile');
          } else {
            context.go('/dashboard/0');
          }
        }

        if (userProvider.user?.uid != null) {
          navigateBasedOnUserState();
        }
      }
    } on FirebaseAuthException catch (e) {
      "Firebase err: ${e.code}".red.log();
      rethrow;
    } catch (e) {
      "Outh err: ${e.toString()}".red.log();
      rethrow;
    }
  }

  String getFriendlyFirebaseAuthError(e) {
    String errorCode = e is FirebaseAuthException ? e.code : 'unknown';
    "Firebase Auth Error: $errorCode".red.log();

    switch (errorCode) {
      case 'captcha-check-failed':
        return 'אימות האבטחה (reCAPTCHA) נכשל. אנא רענן את העמוד ונסה שוב. אם הבעיה נמשכת, פנה לתמיכה.';
      case 'admin-restricted-operation':
        return 'פעולה זו מוגבלת למנהלים בלבד. אם אתה משתמש במספר טלפון המיועד לבדיקות, נסה מספר אחר או פנה לתמיכה.';
      case 'invalid-phone-number':
        return 'מספר הטלפון שהוזן אינו תקין.';
      case 'too-many-requests':
        return 'נשלחו יותר מדי בקשות ממכשיר זה. אנא נסה שוב מאוחר יותר.';
      case 'session-expired':
        return 'תוקף קוד האימות פג. אנא שלח קוד חדש.';
      case 'invalid-verification-code':
        return 'קוד האימות שהוזן שגוי.';
      case 'network-request-failed':
        return 'בעיית רשת. אנא בדוק את חיבור האינטרנט שלך ונסה שוב.';
      default:
        return 'אירעה שגיאה לא צפויה. אנא נסה שוב מאוחר יותר או פנה לתמיכה. (קוד: $errorCode)';
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Phone Authentication Methods
  Future<void> verifyPhoneNumber(
    String phoneNumber,
    BuildContext context, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      'Starting phone verification for: $phoneNumber'.yellow.log();
      'Platform: ${kIsWeb ? "Web" : "Mobile"}'.yellow.log();

      // Local development bypass
      if (EnvironmentConfig.environment == Environment.local) {
        'Local development mode: Simulating SMS sent'.yellow.log();
        _verificationId = "local-test-verification-id";
        onCodeSent(
            'קוד אימות נשלח למספר $phoneNumber (מצב פיתוח - השתמש בקוד: 123456)');
        return;
      }

      if (kIsWeb) {
        // Web implementation with reCAPTCHA
        try {
          'Attempting web phone sign in...'.yellow.log();

          _webConfirmationResult =
              await auth.signInWithPhoneNumber(phoneNumber);
          'Successfully sent verification code'.green.log();
          onCodeSent('קוד אימות נשלח למספר $phoneNumber');
        } catch (e) {
          'Web phone auth error: $e'.red.log();
          onError(getFriendlyFirebaseAuthError(e));
        }
      } else {
        // Mobile implementation
        await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-sign in on Android
            await auth.signInWithCredential(credential);
            if (context.mounted) {
              signInWithCredential(
                  await auth.signInWithCredential(credential), context);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            String errorMessage = 'שגיאה באימות מספר הטלפון';
            if (e.code == 'invalid-phone-number') {
              errorMessage = 'מספר הטלפון אינו תקין';
            } else if (e.code == 'too-many-requests') {
              errorMessage = 'יותר מדי ניסיונות. נסה שוב מאוחר יותר';
            } else if (e.code == 'operation-not-allowed') {
              errorMessage = 'אימות SMS לא מופעל. פנה למנהל המערכת';
            }
            'Phone auth error: ${e.code} - ${e.message}'.red.log();
            onError(getFriendlyFirebaseAuthError(e));
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            onCodeSent('קוד אימות נשלח למספר $phoneNumber');
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 120),
        );
      }
    } catch (e) {
      'Phone verification error: $e'.red.log();
      onError('שגיאה כללית באימות: ${e.toString()}');
    }
  }

  Future<void> verifyOTP(
    String otp,
    BuildContext context, {
    required Function(String) onError,
  }) async {
    try {
      UserCredential credential;

      // Local development bypass
      if (EnvironmentConfig.environment == Environment.local &&
          _verificationId == "local-test-verification-id") {
        if (otp == "123456") {
          'Local development: Valid test code entered'.green.log();
          try {
            // Create or sign in with test user for local development
            const testEmail = "test@mental-coach-local.com";
            const testPassword = "test123456";

            UserCredential credential;
            try {
              credential = await auth.signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              );
            } catch (signInError) {
              credential = await auth.createUserWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              );
              'Created test user for local development'.green.log();
            }

            if (context.mounted) {
              signInWithCredential(credential, context);
            }
          } catch (e) {
            onError('שגיאה בהתחברות למצב פיתוח: ${e.toString()}');
          }
        } else {
          onError('קוד שגוי. במצב פיתוח השתמש בקוד: 123456');
        }
        return;
      }

      if (kIsWeb && _webConfirmationResult != null) {
        // Web verification
        credential = await _webConfirmationResult!.confirm(otp);
      } else if (_verificationId != null) {
        // Mobile verification
        PhoneAuthCredential phoneCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        credential = await auth.signInWithCredential(phoneCredential);
      } else {
        throw Exception('לא נמצא תהליך אימות פעיל');
      }

      if (context.mounted) {
        signInWithCredential(credential, context);
      }
    } on FirebaseAuthException catch (e) {
      onError(getFriendlyFirebaseAuthError(e));
    } catch (e) {
      'OTP verification error: $e'.red.log();
      onError(getFriendlyFirebaseAuthError(e));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // You can handle specific errors here if needed,
      // for now, we rethrow to be caught in the UI.
      throw Exception(e.message);
    }
  }
}
