import 'package:flutter/material.dart';

class PageLayoutWithoutTitle extends StatelessWidget {
  final Widget child;

  const PageLayoutWithoutTitle({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
