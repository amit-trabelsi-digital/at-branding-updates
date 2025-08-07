import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/top_image_layout.dart';
import 'package:provider/provider.dart';

class MatchSummery extends StatefulWidget {
  final String? id;
  const MatchSummery({super.key, required this.id});
  @override
  State<MatchSummery> createState() => _MatchSummeryState();
}

class _MatchSummeryState extends State<MatchSummery> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _matchIndexSelected = 0;
  Match? selectedMatch;
  Team? oponnentTeam;
  TextEditingController matchNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    handleInitlState();
  }

  void handleInitlState() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    selectedMatch = userProvider.user?.matches
        ?.firstWhere((match) => match.id == widget.id);
    oponnentTeam = userProvider.user!.team?.id == selectedMatch?.homeTeam.id
        ? selectedMatch?.awayTeam
        : selectedMatch?.homeTeam;
  }

  void handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await AppFetch.fetch('/users/update-match/${widget.id}',
          method: 'PUT',
          headers: {
            'Custom-Header': 'Value'
          },
          body: {
            'matchResult': _matchIndexSelected == 0
                ? 'win'
                : _matchIndexSelected == 1
                    ? 'draw'
                    : 'lose',
            'investigation': true,
            'note': matchNoteController.text,
          });

      if (response.statusCode == 200 && mounted) {
        print('Response data: ${response.body}');
        final Match newMatch = Match.fromJson(jsonDecode(response.body));
        userProvider.updateMatch(newMatch);

        // showAppNotifyDraw(context,
        //         isPersistent: true,
        //         seconds: 10,
        //         audioUrl:
        //             'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%AA%D7%97%D7%A7%D7%99%D7%A8%20-%20%D7%9B%D7%A0%D7%99%D7%A1%D7%94.mp3?alt=media&token=177cda12-226f-4b67-9691-40c5d4a0051a',
        //         audioImageUrl: 'images/eitan.png',
        //         title: 'כל הכבוד! ',
        //         message: ' ',
        //         primaryButtonLabel: 'אני רוצה להתכונן לדבר הבא >',
        //         primaryButtonAction: '0020 , Click , Enter Investigation');

        context.push('/dashboard/2}');
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const double cardPadding = 18;
    final double screenWidth = MediaQuery.of(context).size.width;

    return TopImageLayout(
      title: 'סיכום משחק',
      imageSrc: 'images/match_banner.png',
      formKey: _formKey,
      cardChildren: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(formatDateToHebrew(selectedMatch?.date, short: true),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                )),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Text('נגד ${oponnentTeam?.name}',
                style: TextStyle(
                  height: 1.2,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ))),
        SizedBox(height: 20),
        AppDivider(
          xMargin: 0,
          height: 2,
          // customColor: AppColors.primary,
        ),
        SizedBox(height: 15),
        AppSubtitle(
          verticalMargin: 0,
          subTitle: 'מי ניצח?',
          textAlign: TextAlign.start,
          fontSize: 20,
          isBold: true,
        ),
        SizedBox(height: 15),
        Center(
          child: AppToggleButtons(
            isSelected: [
              _matchIndexSelected == 0,
              _matchIndexSelected == 1,
              _matchIndexSelected == 2
            ],
            onPressed: (index) {
              setState(() {
                _matchIndexSelected = index;
              });
            },
            fontSize: 24,
            buttonsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            screenWidth: screenWidth - cardPadding,
            labels: ['נצחון', 'תיקו', 'הפסד'],
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xfff9e7ff),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'icons/info-icon.png',
                width: 24,
                height: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'מזכירים שתוצאת המשחק היא הדבר הכי פחות חשוב. היא תעזור לך לזכור באיזה משחק מדובר במסך ההסטוריה.',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppDivider(
          xMargin: 5,
          height: 1,
        ),
        SizedBox(height: 15),
        AppSubtitle(subTitle: 'הערות ודגשים למשחק הבא'),
        AppFormField(
          isTextArea: true,
          minLines: 5,
          validationMessage: 'שגיאה',
          controller: matchNoteController,
        ),
      ],
      additionalChildren: [
        SizedBox(height: 0),
        SizedBox(
          child: AppButton(
            action: '0013 , Click , Submit Match Summery',
            pHeight: 15,
            onPressed: handleSubmit,
            label: 'השלמת דיווח',
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
