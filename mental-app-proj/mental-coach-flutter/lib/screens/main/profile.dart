import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_goals_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';
import 'package:mental_coach_flutter_firebase/widgets/draws/outline_text.dart';
import 'package:mental_coach_flutter_firebase/widgets/draws/shirt_static.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_loading_indicator.dart';

import '../../helpers/helpers.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Changed to listen: true to rebuild when user data changes
    final userProvider = Provider.of<UserProvider>(context);

    // Check if essential user data is loaded
    final bool isLoading = userProvider.user == null ||
        userProvider.user?.selectedTeamColor?.hex1 == null;

    if (isLoading) {
      return const Center(
        child: AppLoadingIndicator(
          showMessage: true,
          message: 'טוען פרופיל...',
        ),
      );
    }

    
    final String lastName = userProvider.user?.lastName ?? '';
    final String subscriptionType =
        toBeginningOfSentenceCase(userProvider.user?.subscriptionType ?? '') ??
            '';

    "userProvider.user?.selectedTeamColor?.hex1 ${userProvider.user?.selectedTeamColor?.hex1}"
        .green
        .log();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          AppLabel(
            fontWeight: FontWeight.w400,
            title: '${userProvider.user?.firstName ?? ''} ${userProvider.user?.lastName ?? ''}',
            subTitle:
                '${getLabelByValue(positions, userProvider.user?.position ?? 'ST')} | ${userProvider.user?.team?.name ?? userProvider.user?.userTeam?.name ?? ''}',
            fontSize: 24,
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          if (subscriptionType.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'מנוי: $subscriptionType',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 30,
          ),
          Container(
              width: 240,
              height: 240,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // color: Colors.white,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowGrey, // Shadow color with opacity
                      spreadRadius: 1, // How much the shadow spreads
                      blurRadius: 10, // Softness of the shadow
                      offset: Offset(0, 0), // Changes position of shadow (X, Y)
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(180))),
              child: GestureDetector(
                onTap: () => context.push('/set-profile'),
                // onTap: () => context.push('/profile/edit'),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 26),
                    child: Stack(children: [
                      CustomPaint(
                        size: const Size(140, 180),
                        painter: TShirtPainterStatic(
                          shirtBaseColor: hexToFlutterColor(
                              userProvider.user?.selectedTeamColor?.hex1 ??
                                  '#9E9E9E'),
                          stripeColor: hexToFlutterColor(
                              userProvider.user?.selectedTeamColor?.hex2 ??
                                  '#5C5C5C'),
                        ),
                      ),
                      Positioned(
                          top: 11,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: OutlinedText(
                              text: lastName,
                              fontSize: 36,
                            ),
                          )),
                      Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: OutlinedText(
                              text: userProvider.user?.playerNumber ?? '10',
                              outlineWidth: 2.2,
                              fontSize: 100,
                            ),
                          )),
                    ]),
                  ),
                ),
              )),
          const SizedBox(
            height: 20,
          ),
          // Align(
          //   child: AppSubtitle(subTitle: 'עיניים על הכדור'),
          // ),
          AppGoalsCard(
            dreamText: userProvider.user?.theDream ?? '',
            breakOutSeasonText: userProvider.user?.breakOutSeason ?? '',
          ),
        ],
      ),
    );
  }
}
