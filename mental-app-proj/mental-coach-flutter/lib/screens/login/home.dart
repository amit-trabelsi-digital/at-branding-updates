import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/login_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';

import '../../data/lists.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _creditOpacity = 1.0; // קרדיט מופיע בהתחלה

  @override
  void initState() {
    super.initState();
    // הכפתור מופיע אחרי 1.5 שניות
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // הקרדיט נעלם אחרי 1.8 שניות (קצת אחרי שהכפתור מתחיל להופיע)
    Future.delayed(const Duration(milliseconds: 1800), () {
      setState(() {
        _creditOpacity = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Background(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  opacity: _opacity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.66),
                      Container(
                        width: 145,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.primary),
                        child: Center(
                          heightFactor: 1.1,
                          child: Text(
                            'איתן עזריה',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
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
                      // ),
                      const AppSubtitle(
                        subTitle: 'לככב ברגע האמת במשחק',
                        verticalMargin: 0,
                        color: Colors.white,
                        isBold: false,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 30),
                          child: AppButton(
                            // Remove the action parameter or ensure it's properly handled
                            action: '0005ss , Click , Create Account',
                            isLight: true,
                            label: 'כניסה',
                            fontSize: 24,
                            pHeight: 15,
                            onPressed: () {
                              context.push('/login');
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // הוספת גרסה וקרדיטים במרכז (מאחורי הכפתור)
            Positioned(
              bottom: screenHeight * 0.25, // מיקום מאחורי הכפתור
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _creditOpacity,
                child: Consumer<DataProvider>(
                  builder: (context, dataProvider, _) => Column(
                    children: [
                      if (dataProvider.appVersion.isNotEmpty)
                        Text(
                          'גרסה ${dataProvider.appVersion}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () async {
                          final Uri url =
                              Uri.parse('https://amit-trabelsi.co.il');
                          if (!await launchUrl(url,
                              mode: LaunchMode.externalApplication)) {
                            print('Could not launch $url');
                          }
                        },
                        child: Text(
                          dataProvider.credits,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
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
