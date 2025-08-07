import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;
  final double? width;
  final double? height;
  final double? minHeight;
  final bool? softShadow;
  final bool bottomRadiusZero;

  const AppCard({
    required this.child,
    this.elevation = 2.0, // Default subtle shadow
    this.borderRadius = 16.0,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(2.0),
    this.border, // Optional border
    this.width,
    this.height,
    this.minHeight,
    this.softShadow,
    this.bottomRadiusZero = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: height != null ? BoxConstraints(minHeight: height!) : null,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: bottomRadiusZero
              ? BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                )
              : BorderRadius.circular(borderRadius),
          boxShadow: elevation > 0
              ? [
                  softShadow == true
                      ? AppShadows.softShadow
                      : AppShadows.defaultShadow
                ]
              : [],
          border: border // Optional border
          ),
      padding: padding,
      child: child,
    );
  }
}
