import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/service/auth.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  final AuthMethods _authMethods = AuthMethods();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _codeSent = false;
  String _phoneNumber = '';
  String _errorMessage = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    phone = phone.replaceAll(RegExp(r'\D'), '');

    // Add country code if not present
    if (phone.startsWith('0')) {
      phone = '972${phone.substring(1)}';
    } else if (!phone.startsWith('972')) {
      phone = '972$phone';
    }

    return '+$phone';
  }

  Future<void> _sendVerificationCode() async {
    // בדיקת תקינות מספר הטלפון
    if (_phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'נא להזין מספר טלפון';
      });
      return;
    }

    if (_phoneController.text.length < 9) {
      setState(() {
        _errorMessage = 'מספר טלפון לא תקין';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    _phoneNumber = _formatPhoneNumber(_phoneController.text);

    await _authMethods.verifyPhoneNumber(
      _phoneNumber,
      context,
      onCodeSent: (message) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 6) {
      setState(() {
        _errorMessage = 'נא להזין קוד אימות תקין';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await _authMethods.verifyOTP(
      _otpController.text,
      context,
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                  Icons.arrow_back), // שונה מ-arrow_forward ל-arrow_back
              onPressed: () => context.go('/start'),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: AppCard(
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppTitle(title: 'התחברות עם SMS'),
                      const SizedBox(height: 8),
                      AppSubtitle(
                        subTitle: _codeSent
                            ? 'הזן את הקוד שנשלח למספר $_phoneNumber'
                            : 'הזן את מספר הטלפון שלך',
                      ),
                      if (kIsWeb && !_codeSent) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'לבדיקה מקומית: השתמש במספר 0501234567',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (!_codeSent) ...[
                        AppFormField(
                          controller: _phoneController,
                          title: 'מספר טלפון',
                          textHint: '050-1234567',
                          numbersOnly: true,
                          maxLength: 10,
                          validationMessage:
                              _errorMessage.isEmpty ? null : _errorMessage,
                        ),
                      ] else ...[
                        Pinput(
                          controller: _otpController,
                          length: 6,
                          showCursor: true,
                          defaultPinTheme: PinTheme(
                            width: 56,
                            height: 56,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 56,
                            height: 56,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _codeSent = false;
                                    _otpController.clear();
                                    _errorMessage = '';
                                  });
                                },
                          child: const Text('שנה מספר טלפון'),
                        ),
                      ],
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: _codeSent ? 'אמת קוד' : 'שלח קוד אימות',
                        onPressed: _isLoading
                            ? null
                            : (_codeSent ? _verifyOTP : _sendVerificationCode),
                        isLoading: _isLoading,
                        action: 'phone_auth',
                      ),
                      const SizedBox(height: 16),
                      if (!_codeSent)
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => context.go('/start'),
                          child: const Text('חזור'),
                        ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'האתר מוגן על ידי reCAPTCHA',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
