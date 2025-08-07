import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:provider/provider.dart'; // Add provider package
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart'; // Import UserProvider
import 'package:url_launcher/url_launcher.dart';

class PageLayout extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? padding;
  final Widget? optionalWidget;

  const PageLayout({
    this.title,
    required this.child,
    this.padding,
    this.optionalWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding ?? 20),
      child: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<UserProvider>(context, listen: false)
              .refreshUserData();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.transparent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: optionalWidget != null
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        children: [
                          // כותרת עם שם המשתמש
                          Expanded(
                            child: Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                final String firstName =
                                    userProvider.user?.firstName ?? '';
                                final String lastName =
                                    userProvider.user?.lastName ?? '';
                                final String fullName =
                                    '$firstName $lastName'.trim();
                                final String displayTitle = fullName.isNotEmpty
                                    ? fullName
                                    : (title ?? '');

                                return AppTitle(
                                  title: displayTitle,
                                  verticalMargin: 0,
                                );
                              },
                            ),
                          ),
                          // כפתור וואצסאפ בצד שמאל - מוצג רק במסך הדשבורד
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final String? phone = userProvider.user?.phone;
                              final bool hasPhone =
                                  phone != null && phone.isNotEmpty;

                              // הצג את הכפתור רק אם יש מספר טלפון ואנחנו במסך הדשבורד
                              final String firstName =
                                  userProvider.user?.firstName ?? '';
                              final String lastName =
                                  userProvider.user?.lastName ?? '';
                              final String fullName =
                                  '$firstName $lastName'.trim();
                              final bool isDashboard =
                                  title == fullName || title == 'דשבורד';

                              if (!hasPhone || !isDashboard) {
                                return SizedBox.shrink();
                              }

                              return GestureDetector(
                                onTap: () async {
                                  // עיבוד מספר הטלפון לפורמט וואטסאפ
                                  String formattedPhone = phone.replaceAll(
                                      RegExp(r'[^\d]'),
                                      ''); // הסרת כל התווים שאינם ספרות
                                  if (formattedPhone.startsWith('0')) {
                                    formattedPhone = '972' +
                                        formattedPhone.substring(
                                            1); // החלפת 0 בקוד מדינה של ישראל
                                  }

                                  final Uri whatsappUrl = Uri.parse(
                                      'https://wa.me/$formattedPhone');
                                  if (!await launchUrl(whatsappUrl,
                                      mode: LaunchMode.externalApplication)) {
                                    print('Could not launch WhatsApp');
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ווטסאפ למאמן',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      SvgPicture.asset(
                                        'icons/whatsapp-icon.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (optionalWidget != null) optionalWidget!,
                        ],
                      ),
                      child,
                      SizedBox(
                          height:
                              130), // הוספת רווח בתחתית כדי שהתוכן לא יוסתר מתחת לתפריט
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
