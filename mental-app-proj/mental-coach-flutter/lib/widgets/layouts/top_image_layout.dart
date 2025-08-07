import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:go_router/go_router.dart';

class TopImageLayout extends StatelessWidget {
  final String title;
  final String imageSrc;
  final bool darkLinear;
  final List<Widget> cardChildren;
  final List<Widget>? additionalChildren; // Add additionalChildren property
  final GlobalKey<FormState> formKey;
  final bool showBackButton; // Add back button parameter
  const TopImageLayout({
    super.key,
    required this.title,
    required this.imageSrc,
    required this.cardChildren,
    required this.formKey,
    this.darkLinear = false,
    this.additionalChildren,
    this.showBackButton = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    const double cardPadding = 18;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Stack(
            children: [
              Container(
                height: 360,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imageSrc),
                    fit: BoxFit.cover,
                  ),
                ),
                child: darkLinear
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black, // Dark color at the bottom
                              const Color.fromARGB(
                                  76, 0, 0, 0), // Transparent at the top
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
              // Title with back button
              Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button aligned to right
                      if (showBackButton)
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            // בדיקה אם יש דף קודם בהיסטוריה
                            if (GoRouter.of(context).canPop()) {
                              context.pop();
                            } else {
                              // אם אין דף קודם, נחזור לדשבורד
                              context.go('/dashboard/0');
                            }
                          },
                        ),
                      // Title aligned to left
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AppTitle(
                            color: Colors.white,
                            title: title,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.only(top: 250, bottom: 100),
                    child: SizedBox(
                      width: screenWidth - 50,
                      child: Column(
                        children: [
                          AppCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 0,
                                children: [...cardChildren],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width: screenWidth - 50,
                            child: Column(
                              children: [
                                // Add additional children
                                if (additionalChildren != null)
                                  ...additionalChildren!,
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
