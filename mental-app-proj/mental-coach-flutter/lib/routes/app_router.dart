import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/routes/page_transitions.dart';
import 'package:mental_coach_flutter_firebase/screens/general/splash_screen.dart';
import 'package:mental_coach_flutter_firebase/screens/login/forgot_password_screen.dart';
import 'package:mental_coach_flutter_firebase/screens/login/goals_profile.dart';
import 'package:mental_coach_flutter_firebase/screens/login/home.dart';
import 'package:mental_coach_flutter_firebase/screens/login/login.dart';
import 'package:mental_coach_flutter_firebase/screens/login/phone_login.dart';
import 'package:mental_coach_flutter_firebase/screens/login/phone_login_new.dart';
import 'package:mental_coach_flutter_firebase/screens/login/otp_verification_screen.dart';
import 'package:mental_coach_flutter_firebase/screens/main/add_match.dart';
import 'package:mental_coach_flutter_firebase/screens/main/cases_and_reactions.dart';
import 'package:mental_coach_flutter_firebase/screens/main/main_screen.dart';
import 'package:mental_coach_flutter_firebase/screens/main/event_investigation.dart';
import 'package:mental_coach_flutter_firebase/screens/main/match_summery.dart';
import 'package:mental_coach_flutter_firebase/screens/main/prepare_match.dart';
import 'package:mental_coach_flutter_firebase/screens/main/training.dart';
import 'package:mental_coach_flutter_firebase/screens/main/training_lesson.dart';
import 'package:mental_coach_flutter_firebase/screens/main/training_exercise.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login/set_profile.dart';

class DeeplinkRouter {
  static late GoRouter router;

  static void initialize(BuildContext context) {
    router = createRouter(context);
  }
}

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    debugLogDiagnostics: true, // For debugging purposes
    refreshListenable: Provider.of<UserProvider>(context, listen: false),
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final loggedIn = userProvider.user?.uid != null;
      final onAuthFlow = ['/start', '/login', '/phone-login', '/phone-login-new', '/otp-verify', '/error']
          .contains(state.uri.toString());

      if (userProvider.isLoading) {
        return null; // Don't redirect while loading
      }

      // If the user is not logged in and not on an auth-related page, redirect to start
      if (!loggedIn && !onAuthFlow) {
        return '/start';
      }

      // If the user is logged in...
      if (loggedIn) {
        // ...but hasn't completed their profile, redirect them.
        if (userProvider.user?.setProfileComplete == false) {
          return '/set-profile';
        }
        // ...or hasn't completed their goals, redirect them.
        if (userProvider.user?.setGoalAndProfileComplete == false) {
          return '/set-goals-profile';
        }

        // If they are logged in and profiles are complete, but they are on an auth page, send to dashboard
        if (onAuthFlow || state.uri.toString() == '/') {
          return '/dashboard/0';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(), // Your main screen
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const Home(), // Your main screen
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LogIn(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLogin(),
      ),
      GoRoute(
        path: '/phone-login-new',
        builder: (context, state) => const PhoneLoginNew(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            phoneNumber: extras?['phoneNumber'] ?? '',
            devCode: extras?['devCode'],
          );
        },
      ),
      GoRoute(
        path: '/set-profile',
        builder: (context, state) => SetProfilePage(),
      ),
      GoRoute(
        path: '/set-goals-profile',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomReverseTransitionPage(
                key: state.pageKey, child: GoalsProfilePage()),
      ),
      GoRoute(
        path: '/cases-and-reactions',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomReverseTransitionPage(
                key: state.pageKey, child: CaseAndReactions()),
      ),
      GoRoute(
        path: '/dashboard/:choosenIndex',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomReverseTransitionPage(
          key: state.pageKey,
          child: MainScreen(
              choosenIndex: state.pathParameters['choosenIndex'] ?? '0'),
        ),
      ),
      GoRoute(
        path: '/add-match',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return JumpFromDownTransitionPage(
            key: state.pageKey,
            child: AddMatch(status: 'match'),
          );
        },
      ),
      GoRoute(
        path: '/add-match/training',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return JumpFromDownTransitionPage(
            key: state.pageKey,
            child: AddMatch(status: 'training'),
          );
        },
      ),
      GoRoute(
        path: '/edit-match/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return JumpFromDownTransitionPage(
            key: state.pageKey,
            child: AddMatch(
              status: 'match',
              matchId: state.pathParameters['id'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/match-summery/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return JumpFromDownTransitionPage(
            key: state.pageKey,
            child: MatchSummery(id: state.pathParameters['id'] ?? '123'),
          );
        },
      ),
      GoRoute(
        path: '/match-investigation/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomReverseTransitionPage(
            key: state.pageKey,
            child: EventInvestigation(
              id: state.pathParameters['id'] ?? '123',
              event: 'match',
            ),
          );
        },
      ),
      GoRoute(
        path: '/training-investigation/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomReverseTransitionPage(
            key: state.pageKey,
            child: EventInvestigation(
              id: state.pathParameters['id'] ?? '123',
              event: 'training',
            ),
          );
        },
      ),
      GoRoute(
        path: '/match-prepare/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomReverseTransitionPage(
            key: state.pageKey,
            child: PrepareMatch(
              id: state.pathParameters['id'] ?? '123',
              event: 'match',
            ),
          );
        },
      ),
      GoRoute(
        path: '/training-prepare/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return CustomReverseTransitionPage(
            key: state.pageKey,
            child: PrepareMatch(
                id: state.pathParameters['id'] ?? '123', event: 'training'),
          );
        },
      ),
      GoRoute(
        path: '/training',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TrainingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/training/lesson/:id',
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['id'] ?? '';

          return CustomTransitionPage(
            key: state.pageKey,
            child: TrainingLessonScreen(lessonId: lessonId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/training/lesson/:lessonId/exercise/:exerciseId',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomReverseTransitionPage(
                key: state.pageKey,
                child: TrainingExercisePage(
                  lessonId: state.pathParameters['lessonId'] ?? '',
                  exerciseId: state.pathParameters['exerciseId'] ?? '',
                )),
      ),

      // הוסף דף שגיאה
      GoRoute(
        path: '/error',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('שגיאה')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text('אירעה שגיאה בניווט'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('חזרה לדף הבית'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
