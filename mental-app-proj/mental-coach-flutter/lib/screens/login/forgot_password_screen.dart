import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/service/auth.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthMethods()
            .sendPasswordResetEmail(email: _emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('מייל לאיפוס סיסמה נשלח בהצלחה.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('שגיאה בשליחת המייל: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'איפוס סיסמה',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'הזן את כתובת המייל שלך ואנו נשלח לך לינק לאיפוס הסיסמה.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              AppFormField(
                controller: _emailController,
                textHint: 'מייל',
                validationMessage: 'אנא הזן כתובת מייל תקינה',
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'שלח לינק לאיפוס',
                onPressed: _isLoading ? null : _sendResetLink,
                isLoading: _isLoading,
                color: AppColors.primary,
                action: 'send_reset_link',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
