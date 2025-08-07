// ignore_for_file: use_super_parameters

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({
    required LocalKey key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
          transitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        );
}

class DismissibleDetailsPage extends CustomTransitionPage<void> {
  DismissibleDetailsPage({
    required LocalKey key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
          barrierDismissible: true,
          barrierColor: Colors.black38,
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class CustomReverseTransitionPage extends CustomTransitionPage<void> {
  CustomReverseTransitionPage({required Widget child, required LocalKey key})
      : super(
          key: key,
          child: child,
          barrierDismissible: true,
          barrierColor: Colors.black38,
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class JumpFromDownTransitionPage extends CustomTransitionPage<void> {
  JumpFromDownTransitionPage({required Widget child, required LocalKey key})
      : super(
          key: key,
          child: child,
          barrierDismissible: true,
          barrierColor: Colors.black38,
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
        );
}
