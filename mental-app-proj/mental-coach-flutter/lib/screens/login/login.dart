// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/auth.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_authentication_button.dart';
import 'package:provider/provider.dart'; // Import to check the platform
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";
  bool isLoading = false;
  bool isGoogleLoading = false;
  bool isAppleLoading = false;

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Refresh user data to save session
      await Provider.of<UserProvider>(context, listen: false).refreshUserData();

      context.go('/dashboard/0');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: SizedBox(
          height: 100,
          child: Text(
            "אימייל או סיסמה אינם נכונים",
            style: TextStyle(fontSize: 18.0, color: AppColors.pink),
          ),
        )));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16.0),
        ),
        backgroundColor: Colors.red.shade700,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        isGoogleLoading = true;
      });

      await AuthMethods().signInWithGoogle(context);
    } catch (e) {
      _showErrorMessage('התחברות דרך Google נכשלה: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      setState(() {
        isAppleLoading = true;
      });

      await AuthMethods().signInWithAppleHandler(context);
    } catch (e) {
      _showErrorMessage('התחברות דרך Apple נכשלה: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isAppleLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Handle auth errors here instead of in build
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.authError != null) {
      // Use a post-frame callback to show the SnackBar after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userProvider.authError!)),
        );
        // Clear the error after showing it\
        // userProvider.clearErrors();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/screenPic.png"), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    const Color.fromARGB(
                        167, 0, 0, 0), // Transparent at the top
                    const Color.fromARGB(
                        0, 61, 61, 61), // Dark color at the bottom
                  ],
                ),
              ), // Semi-transparent overlay
            ),
            SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: SizedBox(
                  height: screenHeight,
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 145,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.primaryDark),
                        child: const Center(
                          heightFactor: 1.1,
                          child: Text(
                            'איתן עזריה',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'המאמן המנטלי',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 70,
                          height: 0.9,
                          color: Colors.white,
                          fontFamily: 'Barlev',
                          fontWeight: FontWeight.w700,
                          wordSpacing: -1,
                        ),
                      ),
                      const AppSubtitle(
                        subTitle: 'לככב ברגע האמת במשחק',
                        verticalMargin: 0,
                        color: Colors.white,
                        isBold: false,
                      ),
                      const SizedBox(
                          height:
                              30), // Spacer between title and the start of the card
                      AppCard(
                          bottomRadiusZero: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerRight,
                                child: AppTitle(
                                  title: 'כניסה לחשבון',
                                  verticalMargin: 5,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // הצגת כפתור Google רק בסביבה לוקלית
                              if (EnvironmentConfig.environment ==
                                  Environment.local) ...[
                                AppAuthenticationButton(
                                  text: 'כניסה עם Gmail',
                                  isLoading: isGoogleLoading,
                                  onPressed: isGoogleLoading
                                      ? null
                                      : _handleGoogleSignIn,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                              AppAuthenticationButton(
                                text: 'כניסה עם SMS',
                                icon: Icons.phone,
                                isLoading: false,
                                onPressed: () {
                                  context.go('/phone-login-new');
                                },
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: 138,
                                      height: 2,
                                      color: AppColors.grey),
                                  const Text(
                                    'או',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  ),
                                  Container(
                                      width: 138,
                                      height: 2,
                                      color: AppColors.grey),
                                ],
                              ),
                              const Align(
                                  alignment: Alignment.centerRight,
                                  child:
                                      AppSubtitle(subTitle: 'כניסה עם אימייל')),
                              AppFormField(
                                controller: mailcontroller,
                                textHint: 'מייל',
                                validationMessage: 'בבקשה הכנס כתובת מייל',
                                fieldHeight: 12,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              AppFormField(
                                controller: passwordcontroller,
                                textHint: 'סיסמה',
                                validationMessage: 'בבקשה הכנס כתובת מייל',
                                isPassword: true,
                                fieldHeight: 12,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    context.push('/forgot-password');
                                  },
                                  child: const Text("שכחת סיסמה?",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SafeArea(
                                bottom: true,
                                child: Column(
                                  children: [
                                    AppButton(
                                      action: '0006 , Click , Login',
                                      label: 'כניסה',
                                      pHeight: 15,
                                      color: Colors.black,
                                      isLoading: isLoading,
                                      onPressed: () {
                                        if (_formkey.currentState!.validate()) {
                                          setState(() {
                                            email = mailcontroller.text;
                                            password = passwordcontroller.text;
                                          });
                                          userLogin();
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                        'גרסה: ${dataProvider.appVersion} | ${dataProvider.credits}', // Displaying the app version
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey)),
                                    // הוספת הצגת סביבת העבודה
                                    Text(
                                        'סביבה: ${EnvironmentConfig.instance.serverURL.contains('localhost') || EnvironmentConfig.instance.serverURL.contains('192.168') ? 'מקומית' : EnvironmentConfig.instance.serverURL.contains('dev-srv') ? 'פיתוח' : 'ייצור'}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange)),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
