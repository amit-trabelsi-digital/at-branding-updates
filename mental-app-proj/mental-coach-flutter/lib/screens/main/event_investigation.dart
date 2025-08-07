import 'dart:convert';

import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/helpers/notification_helper.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_number_selector.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/top_image_layout.dart';
import 'package:mental_coach_flutter_firebase/widgets/selectors/app_select_slider.dart';
import 'package:provider/provider.dart';

class EventInvestigation extends StatefulWidget {
  final String? id;
  final String event;
  const EventInvestigation({super.key, required this.id, required this.event});
  @override
  State<EventInvestigation> createState() => _EventInvestigationState();
}

class _EventInvestigationState extends State<EventInvestigation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AppSliderController _sliderController = AppSliderController();

  // 0 for home, 1 for away
  final NumberSelectorController _personalityGroupController =
      NumberSelectorController();
  dynamic currentEvent;
  Team? oponnentTeam;
  bool isLastStep = false;
  bool isMatch = false;
  @override
  void initState() {
    super.initState();
    handleInitlState();

    // Add this to subscribe to last step changes
    _sliderController.onLastStepChanged = (bool newIsLastStep) {
      setState(() {
        isLastStep = newIsLastStep;
      });
    };
  }

  void handleInitlState() {
    isMatch = widget.event == 'match';
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    "EventInvestigation ${widget.event}".green.log();

    currentEvent = isMatch
        ? userProvider.user?.matches
            ?.firstWhere((match) => match.id == widget.id)
        : userProvider.user?.trainings
            ?.firstWhere((training) => training.id == widget.id);

    if (isMatch && currentEvent is Match) {
      oponnentTeam = userProvider.user!.team?.id == currentEvent.homeTeam.id
          ? currentEvent.awayTeam
          : currentEvent.homeTeam;
    }

    "${currentEvent?.investigation} INVESTIGATION".green.log();

    // הצגת ההתראה לאחר שהמסך נבנה
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAppNotifyDraw(context,
          isPersistent: true,
          seconds: 10,
          audioUrl:
              'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%AA%D7%97%D7%A7%D7%99%D7%A8%20-%20%D7%9B%D7%A0%D7%99%D7%A1%D7%94.mp3?alt=media&token=177cda12-226f-4b67-9691-40c5d4a0051a',
          audioImageUrl: 'images/eitan.png',
          title: 'לתחקר כמו ווינר ',
          message: ' ',
          primaryButtonLabel: 'אני מוכן!',
          primaryButtonAction: '0020 , Click , Enter Investigation');
    });
  }

  void handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_personalityGroupController.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('נא לבחור מדרג',
              style: TextStyle(fontSize: 20, color: Colors.red))));
      return;
    }
    try {
      final response = await AppFetch.fetch(
          '/users/update-${widget.event}/${widget.id}',
          method: 'PUT',
          headers: {
            'Custom-Header': 'Value'
          },
          body: {
            'goal': {
              'goalName': currentEvent?.goal?.goalName,
              'performed': currentEvent?.goal?.performed,
            },
            'actions': currentEvent?.actions
                ?.map((action) => {
                      'actionName': action.actionName,
                      'performed': action.performed
                    })
                .toList(),
            'personalityGroup': {
              'tag': currentEvent?.personalityGroup?.tag,
              'performed': (_personalityGroupController.value ?? 0) / 5
            },
            'investigation': true,
            'isOpen': false
          });

      if (response.statusCode == 200 && mounted) {
        print('Response data: ${response.body}');

        if (isMatch) {
          //  פה לא חוזר המשחק המעודכן, חוזר המשחק הבא שנפתח
          final Match newMatch = Match.fromJson(jsonDecode(response.body));
          Exception('New Match $newMatch');
          userProvider.updateMatch(newMatch);
          context.push('/match-summery/${widget.id}');
        } else {
          final Training newTraining =
              Training.fromJson(jsonDecode(response.body));

          "New Training ${newTraining.investigation} , ${newTraining.isOpen}"
              .green
              .log();
          userProvider.updateTraining(newTraining);
          context.go('/dashboard/4');
        }
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void handleNextOrCompleteSlider() {
    bool newIsLastStep = _sliderController.isLastStep?.call() ?? false;
    "Parent last step $newIsLastStep".green.log();
    setState(() {
      isLastStep = newIsLastStep;
    });

    print(isLastStep);
    if (isLastStep) {
      // If at the last step
      _sliderController.completeAction?.call();
      // Additional logic if needed
    } else {
      // Try to move to next step
      _sliderController.moveToNextStep?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TopImageLayout(
      title: 'תחקיר אישי',
      imageSrc: 'images/match_banner.png',
      formKey: _formKey,
      cardChildren: [
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(formatDateToHebrew(currentEvent?.date, short: true),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                )),
          ),
        ),
        Align(
            alignment: Alignment.center,
            child: Text(isMatch ? 'נגד ${oponnentTeam?.name}' : 'אימון',
                style: TextStyle(
                  height: 1,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ))),
        SizedBox(height: 10),
        AppDivider(
          xMargin: 0,
          height: 2,
        ),
        AppSliderWithSelect(
          isMatch: isMatch,
          personalityGroupTag:
              currentEvent?.personalityGroup?.tag ?? 'מידע חסר',
          goal: currentEvent!.goal,
          personalityGroupTagController: _personalityGroupController,
          controller: _sliderController, // Pass the controller
          actionArray: currentEvent?.actions,
          onComplete: () {
            currentEvent?.actions?.forEach((action) {
              print(action.performed);
            });
            // Handle completion
          },
        ),
      ],
      additionalChildren: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
              action: '0012 , Click , Submit Match Investigation',
              label: _sliderController.isLastStep?.call() ?? false
                  ? "סיכום משחק"
                  : "המשך >",
              onPressed: _sliderController.isLastStep?.call() ?? false
                  ? handleSubmit
                  : handleNextOrCompleteSlider),
        ),
      ],
    );
  }
}
