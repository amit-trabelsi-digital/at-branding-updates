import 'package:color_simp/color_simp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode, kIsWeb, and kDebugMode
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:in_app_purchase/in_app_purchase.dart'; // הוסר - לא נדרש יותר
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/firebase_options.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/training_provider.dart';
import 'package:mental_coach_flutter_firebase/routes/app_router.dart'; // ודא שזה הנתיב הנכון
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/service/deep_link.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(); // מפתח גלובלי

void main() async {
  // Set to true ONLY for local development to work with a local server.
  // This will be ignored in release mode.
  const bool useLocalServer = false; // Changed to false for Railway deployment

  // Ensure binding is initialized first.
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment based on build mode
  if (kReleaseMode) {
    // In release mode, always use the production server.
    EnvironmentConfig.setEnvironment(Environment.prod);
    "Running in PRODUCTION environment".green.log();
  } else {
    // In debug mode, you can easily switch between local and dev servers.
    final environment = useLocalServer ? Environment.local : Environment.dev;
    EnvironmentConfig.setEnvironment(environment);
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check with proper configuration
  // For localhost development, we'll use a debug token
  await FirebaseAppCheck.instance.activate(
    // Use debug provider for localhost
    webProvider: kDebugMode && kIsWeb
        ? ReCaptchaV3Provider('6Lfo3JYrAAAAAKDcf203X5NutS18IPJX7aPboPsC')
        : ReCaptchaV3Provider('6Lfo3JYrAAAAAKDcf203X5NutS18IPJX7aPboPsC'),
    // Default providers for Android and iOS
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  // Set up reCAPTCHA configuration for Firebase Auth
  if (kIsWeb) {
    // This is crucial - we need to configure the reCAPTCHA for Auth separately
    final auth = FirebaseAuth.instance;

    // Use invisible reCAPTCHA for better UX
    await auth.setSettings(
      appVerificationDisabledForTesting:
          kDebugMode, // Only disable in debug mode
    );

    print(
        'Firebase Auth configured for ${kDebugMode ? "development" : "production"} mode');
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red,
      child: Center(
        child: Text(
          'Error: ${details.exception}',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  };

  try {
    print("Firebase initialized successfully");

    // await FirebaseMessagingService.initialize(); // אתחול FCM - יועבר לביצוע אחרי התחברות
    // In-App Purchase הוסר - לא נדרש יותר
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  final dataProvider = DataProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => dataProvider), // Provide DataProvider instance
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    // Initialize the router before using it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeeplinkRouter.initialize(context);
    });

    _deepLinkService = DeepLinkService(
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
    _deepLinkService.initialize();
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
      scaffoldMessengerKey: scaffoldMessengerKey,
      locale: const Locale('he', 'IL'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('he', 'IL'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'המאמן המנטלי',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        textTheme: GoogleFonts.assistantTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.appBG,
        cardColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(color: AppColors.primary, fontSize: 14),
          actionTextColor: AppColors.pink,
          behavior: SnackBarBehavior.fixed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}

// Placeholder EmailScreen (create a real one in your app)
