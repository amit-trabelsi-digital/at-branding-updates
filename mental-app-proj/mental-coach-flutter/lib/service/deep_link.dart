import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:color_simp/color_simp.dart';
import '../routes/app_router.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  factory DeepLinkService(
      {required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey}) {
    _instance.scaffoldMessengerKey = scaffoldMessengerKey;
    return _instance;
  }

  DeepLinkService._internal()
      : scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> initialize() async {
    await initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    debugPrint('Starting initDeepLinks');
    'Starting initDeepLinks'.green.log();

    try {
      debugPrint('Checking for initial link');
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('Initial deep link: $initialUri');
        'Initial deep link: $initialUri'.green.log();
        handleDeepLink(initialUri);
      } else {
        debugPrint('No initial deep link received');
        'No initial deep link received'.green.log();
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
      'Error getting initial link: $e'.green.log();
    }

    debugPrint('Setting up uriLinkStream listener');
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('Received deep link: $uri');
        'Received deep link: $uri'.green.log();
        handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Error handling deep link: $err');
        'Error handling deep link: $err'.green.log();
      },
      onDone: () {
        debugPrint('uriLinkStream closed');
        'uriLinkStream closed'.green.log();
      },
    );
  }

  void handleDeepLink(Uri uri, {BuildContext? context}) {
    debugPrint('Handling deep link: $uri');
    debugPrint('Handling deep link: ${uri.scheme}');
    debugPrint('Handling deep link: ${uri.host}');
    debugPrint('Handling deep link: ${uri.path}');
    'Handling deep link: $uri'.green.log();
    if (uri.host == 'menta-coach-assetlink.netlify.app') {
      debugPrint('Caught mentalapp://home deep link!');
      'Caught mentalapp://home deep link!'.green.log();

      // route to the home page with the token
      // final token = uri.queryParameters['token'];

      // Use the static router instance to navigate without context
      try {
        DeeplinkRouter.router.go(uri.path);
        // if (token != null) {
        //   debugPrint('Azure AD token: $token');
        //   'Azure AD token: $token'.green.log();
        //   DeeplinkRouter.router.go('/dashboard/2?token=$token');
        // } else {
        // }
      } catch (e) {
        debugPrint('Error navigating via deep link: $e');
        'Error navigating via deep link: $e'.red.log();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error processing deep link: $e')),
        );
      }
    } else {
      debugPrint('Unhandled deep link: $uri');
      'Unhandled deep link: $uri'.green.log();
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Invalid deep link')),
      );
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
