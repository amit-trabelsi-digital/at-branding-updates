import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class PageLayoutWithScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const PageLayoutWithScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight, // Align title to the right
                  child: AppTitle(title: title),
                ),
                // Optional spacing between title and content
                child, // Dynamic child content
                SizedBox(
                    height:
                        130), // הוספת רווח בתחתית כדי שהתוכן לא יוסתר מתחת לתפריט
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Align(
//               alignment: Alignment.centerRight, // Align to the left side
//               child: AppTitle(title: 'יצירת פרופיל'),
//             ),
//             SetProfilePage(),
//           ],
//         ),
//       ),
//     ),
