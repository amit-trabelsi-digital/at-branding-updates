// ignore_for_file: use_build_context_synchronously
import 'package:color_simp/color_simp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/screens/login/login.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", phone = " ";
  bool isLoading = false;

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userSignup() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });
      final newUser = AppUser(email: email, password: password, phone: phone);

      try {
        final createdUser = await signup(newUser);
        print(createdUser);
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        context.go('/set-profile');
      } catch (apiError) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            apiError.toString().replaceAll('Exception: ', '') ==
                    'The email address is already in use by another account.'
                ? 'המייל כבר קיים במערכת'
                : apiError.toString().replaceAll('Exception: ', ''),
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e.code == 'auth/email-already-exists') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: AppTitle(
                    title: 'המאמן המנטלי',
                    fontSize: 70,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    AppFormField(
                        controller: mailController,
                        textHint: 'מייל',
                        validationMessage: 'בבקשה הכנס כתובת מייל'),
                    SizedBox(
                      height: 30.0,
                    ),
                    AppFormField(
                      isPassword: true,
                      controller: passwordController,
                      textHint: 'סיסמה',
                      validationMessage: 'בבקשה הכנס סיסמה',
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    AppFormField(
                        controller: phoneController,
                        textHint: 'טלפון',
                        validationMessage: 'בבקשה הכנס מספר טלפון'),
                    SizedBox(
                      height: 30.0,
                    ),
                    AppButton(
                      action: '0008 , Click , Sign Up',
                      label: 'הרשם',
                      pHeight: 15,
                      isLoading: isLoading,
                      onPressed: () {
                        "SIGN TO TAB".green.log();
                        print('sign app tap');
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailController.text;
                            password = passwordController.text;
                            phone = phoneController.text;
                          });
                          userSignup();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("כבר יש לך חשבון ?",
                    style: TextStyle(
                        color: Color(0xFF8c8e98),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LogIn()));
                  },
                  child: Text(
                    "כניסה",
                    style: TextStyle(
                        color: Color(0xFF273671),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
