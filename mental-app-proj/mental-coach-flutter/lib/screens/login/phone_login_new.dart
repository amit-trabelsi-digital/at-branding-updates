import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../service/otp_service.dart';
import '../../widgets/buttons/app_button.dart';

import '../../widgets/app_subtitle.dart';
import '../../widgets/app_title.dart';

class PhoneLoginNew extends StatefulWidget {
  const PhoneLoginNew({super.key});

  @override
  State<PhoneLoginNew> createState() => _PhoneLoginNewState();
}

class _PhoneLoginNewState extends State<PhoneLoginNew> {
  final OtpService _otpService = OtpService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _includeEmail = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'יש להזין מספר טלפון';
    }
    
    // Remove all non-digits
    String digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Check for valid Israeli mobile number
    if (digits.startsWith('0')) {
      if (digits.length != 10 || !digits.startsWith('05')) {
        return 'מספר טלפון לא תקין';
      }
    } else if (digits.startsWith('972')) {
      if (digits.length != 12 || !digits.startsWith('9725')) {
        return 'מספר טלפון לא תקין';
      }
    } else {
      return 'מספר טלפון לא תקין';
    }
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_includeEmail) return null;
    
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'כתובת אימייל לא תקינה';
    }
    
    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _otpService.sendOTP(
        phoneNumber: _phoneController.text,
        email: _includeEmail && _emailController.text.isNotEmpty 
          ? _emailController.text 
          : null,
      );

      if (!mounted) return;

      if (result['success']) {
        // Navigate to OTP verification screen
        context.push(
          '/otp-verify',
          extra: {
            'phoneNumber': result['phoneNumber'],
            'devCode': result['devCode'],
          },
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'שגיאה בשליחת קוד';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה בחיבור לשרת';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkServiceStatus() async {
    final status = await _otpService.checkServiceStatus();
    if (mounted && status['status'] != 'active') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'שירות SMS במצב פיתוח - הקוד יוצג על המסך',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                Center(
                  child: Column(
                    children: [
                      const AppTitle(title: 'התחברות עם SMS'),
                      const SizedBox(height: 8),
                      const AppSubtitle(
                        subTitle: 'הזן את מספר הטלפון שלך ונשלח לך קוד אימות',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    hintText: '050-1234567',
                    labelText: 'מספר טלפון',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF00A65D)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textDirection: TextDirection.ltr,
                ),
                
                const SizedBox(height: 20),
                
                // Optional Email Toggle
                Row(
                  children: [
                    Checkbox(
                      value: _includeEmail,
                      onChanged: (value) {
                        setState(() {
                          _includeEmail = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF00A65D),
                    ),
                    const Text('הוסף כתובת אימייל (אופציונלי)'),
                  ],
                ),
                
                // Email Field (conditional)
                if (_includeEmail) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'example@email.com',
                      labelText: 'כתובת אימייל',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF00A65D)),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    textDirection: TextDirection.ltr,
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: _isLoading ? 'שולח...' : 'שלח קוד אימות',
                    action: 'send_otp',
                    onPressed: _isLoading ? null : _sendOtp,
                    isLoading: _isLoading,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Alternative Login Methods
                Center(
                  child: Column(
                    children: [
                      const Divider(height: 40),
                      TextButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.email, color: Color(0xFF00A65D)),
                        label: Text(
                          'כניסה עם אימייל',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // WhatsApp Support Link
                      TextButton.icon(
                        onPressed: () async {
                          final message = Uri.encodeComponent(
                            'שלום, אני מנסה להתחבר למערכת המאמן המנטלי ונתקל בבעיה. '
                            'המספר שלי הוא: ${_phoneController.text}'
                          );
                          final whatsappUrl = 'https://wa.me/972506362008?text=$message';
                          
                          try {
                            await launchUrlString(whatsappUrl);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('לא ניתן לפתוח את WhatsApp'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.support_agent, color: Colors.green),
                        label: const Text(
                          'נתקלת בבעיה? צור קשר בוואטסאפ',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                

              ],
            ),
          ),
        ),
      ),
    );
  }
}