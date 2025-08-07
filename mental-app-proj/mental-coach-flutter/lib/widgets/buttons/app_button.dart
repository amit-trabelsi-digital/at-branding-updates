import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color; // Allow null for conditional styling
  final double fontSize;
  final bool isLight; // Prop to toggle light button style
  final double pHeight;
  final bool isLoading; // New prop to indicate loading state
  final Icon? icon; // New prop for the icon
  final String? action;
  final bool disabled;
  final double borderRadius; // New prop for border radius
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.fontSize = 20,
    this.isLight = false, // Default is not light
    this.pHeight = 10,
    this.isLoading = false, // Default is not loading
    this.icon, // Optional icon
    required this.action,
    this.disabled = false,
    this.borderRadius = 8.0, // Default border radius
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ApiService apiService = ApiService();
    final bool isButtonDisabled = isLoading || disabled;

    return Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed != null && !isButtonDisabled) {
            if (action != null && userProvider.user != null) {
              apiService.trackUserActivity(
                  userProvider.user!.id ?? '', action!);
            }
            onPressed!();
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          backgroundColor:
              isLight ? AppColors.borderGrey : (color ?? AppColors.primary),
          disabledBackgroundColor: isLight
              ? AppColors.lightGrey
              : (color ?? AppColors.primary).withAlpha(210),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: pHeight),
          textStyle: TextStyle(
            fontSize: fontSize,
            color: isLight ? AppColors.primary : Colors.white,
            fontFamily: GoogleFonts.assistant().fontFamily,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: 8),
            ],
            if (!isLoading)
              Text(
                label,
                style: TextStyle(
                  color: isLight
                      ? AppColors.primary
                          .withAlpha(isButtonDisabled ? 100 : 255)
                      : AppColors.lightGrey,
                ),
              ),
            if (isLoading) ...[
              SizedBox(
                width: fontSize * 1.3,
                height: fontSize * 1.3,
                child: CircularProgressIndicator(
                  color: isLight ? AppColors.primary : Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
