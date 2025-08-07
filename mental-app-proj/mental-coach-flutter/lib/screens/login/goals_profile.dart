import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_accordion.dart';
import 'package:mental_coach_flutter_firebase/widgets/players/app_video_player.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_number_selector.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout_with_nav.dart';
import 'package:provider/provider.dart';

class GoalsProfilePage extends StatefulWidget {
  const GoalsProfilePage({super.key});

  @override
  State<GoalsProfilePage> createState() => _GoalsProfilePage();
}

class _GoalsProfilePage extends State<GoalsProfilePage> {
  final NumberSelectorController _preasureController =
      NumberSelectorController();
  final NumberSelectorController _confidenceController =
      NumberSelectorController();

  String? breakOutSeason;
  String? theDream;
  int? preasure;
  int? confidence;
  String audiUrl = '';
  bool _isLoading = false; // Add loading state variable

  TextEditingController breakOutSeasoncontroller = TextEditingController();
  TextEditingController theDreamcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  void initializeUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    "${dataProvider.generalData}".green.log();

    audiUrl = dataProvider.generalData['goalsAudioFile']?['fileData']
            ?['path'] ??
        'https://example.com/default-audio.mp3';

    final user = userProvider.user;
    if (user != null) {
      setState(() {
        breakOutSeasoncontroller.text = user.breakOutSeason ?? '';
        theDreamcontroller.text = user.theDream ?? '';
        if (user.currentStatus != null && user.currentStatus!.isNotEmpty) {
          _preasureController.value = user.currentStatus
                  ?.firstWhere((status) => status.title == 'preasure')
                  .rating ??
              0;
          _confidenceController.value = (user.currentStatus
                  ?.firstWhere((status) => status.title == 'confidence')
                  .rating ??
              0);
        }
      });
    }
  }

  void handleSubmit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    var ifTosetGoalAndProfileComplete = (breakOutSeason != null &&
            breakOutSeason!.isNotEmpty &&
            theDream != null &&
            theDream!.isNotEmpty)
        ? true
        : false;

    // בדיקה האם זוהי הפעם הראשונה שהמשתמש ממלא את הטופס
    final isFirstTimeSubmit =
        userProvider.user?.setGoalAndProfileComplete != true;

    try {
      final response =
          await AppFetch.fetch('/users/update', method: 'PUT', headers: {
        'Custom-Header': 'Value'
      }, body: {
        'breakOutSeason': breakOutSeason,
        'theDream': theDream,
        'setGoalAndProfileComplete': ifTosetGoalAndProfileComplete,
        'currentStatus': [
          {
            'title': 'preasure',
            'rating': (_preasureController.value ?? 1),
          },
          {
            'title': 'confidence',
            'rating': (_confidenceController.value ?? 1),
          }
        ],
      });

      if (response.statusCode == 200) {
              userProvider.refreshUserData();
      print('Response data: ${response.body}');

      // מעבר לדשבורד אחרי הגדרת המטרות
      if (isFirstTimeSubmit && mounted) {
        context.push('/dashboard/0');
      }
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    if (mounted) context.push('/dashboard/0');
  }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final String audiUrl =
        dataProvider.generalData['goalsAudioFile']['fileData']['path'];

    return Scaffold(
      body: AppPageLayout(
        title: 'פרופיל ויעדים',
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            spacing: 20,
            children: [
              AppCard(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      AppSubtitle(subTitle: 'מסר חשוב לפני שמתחילים'),
                      SizedBox(height: 10),
                      VideoWidget(
                          videoUrl: Uri.parse(
                              'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%99%D7%A2%D7%93%D7%99%D7%9D.mp4?alt=media&token=c9a643f0-0a6a-4eb8-baf1-7a5bdf081a71'),
                          thumbnailUrl:
                              'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%99%D7%A2%D7%93%D7%99%D7%9D.gif?alt=media&token=90dc5d6f-b98d-41e0-9d29-2ae581003a75',
                          action: '0002 , Click , Goals Video Play'),
                      // AudioWidget(
                      //     audioUrl: UrlSource(dataProvider
                      //                 .generalData['goalsAudioFile']
                      //             ?['fileData']?['path'] ??
                      //         'https://example.com/default-audio.mp3'), // Fallback URL if path is missing
                      //     imageUrl: 'images/eitan.png',
                      //     action: '0003 , Click , Goals Audio Play'),
                      SizedBox(height: 20),
                      //   AppDivider(),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: AppButton(
                      //     action: '0004 , click , play audio',
                      //     pHeight: 5,
                      //     onPressed: () {},
                      //     icon: Icon(
                      //       color: Colors.white,
                      //       size: 40,
                      //       Icons.play_arrow_rounded,
                      //     ),
                      //     label: 'לצפייה לפני שמתחילים',
                      //   ),
                      // ),
                    ],
                  )),
              Accordion(
                title: "החלום",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppDivider(
                    //   xMargin: 0,
                    // ),
                    AppFormField(
                      isTextArea: true,
                      title: 'החלום הגדול',
                      subtitle: 'מה החלום שלך בכדורגל?',
                      validationMessage: 'שגיאה',
                      controller: theDreamcontroller,
                      minLines: 8,
                      allowWrapLabel: true,
                    ),
                    // SizedBox(
                    //   height: 80,
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Accordion(
                title: "עונת הפריצה שלי",
                isExpanded: false,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFormField(
                      isTextArea: true,
                      title: 'מטרה לעונה הקרובה',
                      subtitle: 'מה יהפוך את העונה הזו לעונת הפריצה?',
                      validationMessage: 'שגיאה',
                      controller: breakOutSeasoncontroller,
                      minLines: 8,
                      allowWrapLabel: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Accordion(
                title: "מצב קיים",
                isExpanded: false,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDivider(
                      xMargin: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "בכל אחד מהסעיפים הבאים נרצה לקבל דירוג שלך, כמו שאתה מעריך את עצמך היום. המידע הזה נשמר רק בפרופיל שלך ולא משותף באף מקום אחר. זה הזמן להיות מדויק ואמיתי עם עצמך, כדי שנוכל לסמן יחד את הזדמנויות ולדעת איך להביא אותך בצעדים הנכונים ליעד.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    AppDivider(
                      xMargin: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "לחץ",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "ביום לפני משחק ובדקות שהמשחק מתחיל, אני חווה סימני לחץ, התקשות של השרירים והתמודדות קשה",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NumberSelector(
                        controller: _preasureController,
                        fealList: FEEEL_LIST_1),
                    SizedBox(
                      height: 20,
                    ),
                    AppDivider(
                      xMargin: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "ביטחון",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "כשאני מגיע למגרש אני יודע בראש שאני עומד לתת את כל מה שיש לי ולהיות מעולה",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    NumberSelector(
                      controller: _confidenceController,
                      fealList: FEEEL_LIST_1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  action: '0005 , click , save goals profile',
                  pHeight: 15,
                  onPressed: () {
                    setState(() {
                      breakOutSeason = breakOutSeasoncontroller.text;
                      theDream = theDreamcontroller.text;
                    });
                    handleSubmit();
                  },
                  label: 'שמירת פרופיל והמשך',
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
