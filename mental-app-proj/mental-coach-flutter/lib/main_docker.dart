import 'package:color_simp/color_simp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mental_coach_flutter_firebase/config/environment_config_docker.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/firebase_options.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/training_provider.dart';
import 'package:mental_coach_flutter_firebase/routes/app_router.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/service/deep_link.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

const String appName = 'המאמן המנטלי';

void main() async {
  // הקשר אתחול Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // הגדרת סביבת Docker
  EnvironmentConfig.setEnvironment(Environment.docker);
  "Running in DOCKER environment".green.log();
  
  // אתחול Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase App Check עבור Docker
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(
      const String.fromEnvironment(
        'RECAPTCHA_SITE_KEY',
        defaultValue: 'default-key'
      )
    ),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // אתחול DeepLink service
  final deepLinkService = DeepLinkService(
    scaffoldMessengerKey: scaffoldMessengerKey,
  );
  deepLinkService.initialize();

  // הרצת האפליקציה
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DeepLinkService _deepLinkService;
  
  @override
  void initState() {
    super.initState();
    _clearCacheOnStartup();
    
    // Initialize DeepLink service
    _deepLinkService = DeepLinkService(
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
    _deepLinkService.initialize();
    
    // Initialize the router after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeeplinkRouter.initialize(context);
    });
  }

  Future<void> _clearCacheOnStartup() async {
    try {
      // ניקוי מטמון Firebase Auth
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.currentUser?.reload();
      
      "Cache cleared on startup".yellow.log();
    } catch (e) {
      "Error clearing cache: $e".red.log();
    }
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final router = createRouter(context);
    
    // Set the static router after it's created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeeplinkRouter.router = router;
    });
    
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.assistantTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'),
      ],
      locale: const Locale('he', 'IL'),
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

// פונקציות עזר גלובליות
void showErrorSnackBar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

void showSuccessSnackBar(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}