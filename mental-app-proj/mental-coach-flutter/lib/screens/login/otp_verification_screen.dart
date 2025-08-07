import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../service/otp_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../providers/user_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? devCode;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.devCode,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpService _otpService = OtpService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    
    // Show dev code if in debug mode
    if (widget.devCode != null) {
      _showDevCode();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }
  
  void _showDevCode() {
    if (widget.devCode != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('קוד פיתוח: ${widget.devCode}'),
              duration: const Duration(seconds: 10),
              backgroundColor: Colors.blue,
            ),
          );
        }
      });
    }
  }
  
  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }
  
  bool get _isCodeComplete {
    return _otpCode.length == 6 && _otpCode.isNotEmpty;
  }
  
  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) {
      // Handle backspace
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    } else if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered, verify automatically
        _focusNodes[index].unfocus();
        if (_isCodeComplete) {
          _verifyOTP();
        }
      }
    } else if (value.length == 6) {
      // Handle paste
      for (int i = 0; i < 6; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
      if (_isCodeComplete) {
        _verifyOTP();
      }
    }
    
    setState(() {
      _errorMessage = null;
    });
  }
  
  Future<void> _verifyOTP() async {
    if (!_isCodeComplete) {
      setState(() {
        _errorMessage = 'יש להזין קוד בן 6 ספרות';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _otpService.verifyOTP(code: _otpCode);
      
      if (!mounted) return;
      
      if (result['success']) {
        // Update UserProvider after successful login
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        // Load user data from Firebase/API
        await userProvider.refreshUserData();
        
        // Success - navigate to main app
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'התחברת בהצלחה!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Small delay to ensure UserProvider is updated
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Navigate to dashboard
        if (!mounted) return;
        context.go('/dashboard/0');
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'קוד שגוי';
          if (result['remainingAttempts'] != null) {
            _errorMessage = '${_errorMessage!} (נותרו ${result['remainingAttempts']} ניסיונות)';
          }
        });
        
        // Clear fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'שגיאה באימות הקוד';
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
  
  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _otpService.resendOTP();
      
      if (!mounted) return;
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('קוד חדש נשלח בהצלחה'),
            backgroundColor: Colors.green,
          ),
        );
        _startResendCountdown();
        
        // Show dev code if exists
        if (result['devCode'] != null) {
          widget.devCode != null ? _showDevCode() : null;
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'שגיאה בשליחת קוד חדש';
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
  
  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: index == 0 ? 6 : 1, // Allow paste in first field
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _errorMessage != null ? Colors.red : Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF00A65D),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _onDigitChanged(index, value),
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A65D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  size: 40,
                  color: Color(0xFF00A65D),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Title
              const Text(
                'אימות קוד',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Subtitle
              Text(
                'הזן את הקוד ששלחנו ל-${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpField(index)),
                ),
              ),
              
              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isLoading ? 'מאמת...' : 'אמת קוד',
                  action: 'verify_otp',
                  onPressed: _isCodeComplete && !_isLoading ? _verifyOTP : null,
                  isLoading: _isLoading,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'לא קיבלת קוד?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: _canResend && !_isLoading ? _resendOTP : null,
                    child: Text(
                      _canResend 
                        ? 'שלח שוב' 
                        : 'שלח שוב (${_resendCountdown})',
                      style: TextStyle(
                        color: _canResend 
                          ? const Color(0xFF00A65D) 
                          : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Dev Mode Info
              if (widget.devCode != null)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bug_report, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'מצב פיתוח - קוד: ${widget.devCode}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
              // WhatsApp Support
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  final message = Uri.encodeComponent(
                    'שלום, אני מנסה להתחבר למערכת המאמן המנטלי ונתקל בבעיה באימות קוד SMS. '
                    'המספר שלי הוא: ${widget.phoneNumber}'
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
                icon: const Icon(Icons.support_agent, color: Colors.green, size: 20),
                label: const Text(
                  'זקוק לעזרה? פנה אלינו בוואטסאפ',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}