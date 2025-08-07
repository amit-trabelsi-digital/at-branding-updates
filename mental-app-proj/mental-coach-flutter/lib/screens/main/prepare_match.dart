import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';

import 'package:mental_coach_flutter_firebase/widgets/app_auto_complete.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_choise_chip.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout_with_nav.dart';
import 'package:mental_coach_flutter_firebase/widgets/players/app_mini_audio_player.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:mental_coach_flutter_firebase/helpers/notification_helper.dart';

class PrepareMatch extends StatefulWidget {
  final String? id;
  final String event;

  const PrepareMatch({super.key, required this.id, required this.event});

  @override
  State<PrepareMatch> createState() => _PrepareMatchState();
}

class _PrepareMatchState extends State<PrepareMatch> {
  // General variables
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _actionsKey = GlobalKey();
  final GlobalKey _personalityKey = GlobalKey();
  int _actionIdCounter = 0;
  static const int maxActionFields = 5;
  // Variables for data fetching
  bool _isLoading = true;
  List<String> _goals = [];
  List<String> _actions = [];
  String? _error;
  List<String> tagOptions = [];

  // Variables for form and visibility
  String _selectedGoal = '';
  String selectedTag = ''; // Default selected option
  String selectedGroup = ''; // Default selected option
  final List<Map<String, dynamic>> _selectedActions = [];
  bool _showActions = false;
  bool _showPersonality = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _scrollToWidget(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _fetchData() async {
    String positionValue;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    print(dataProvider.personalityGroups);
    positionValue = userProvider.user?.position ?? 'CB';

    selectedTag = dataProvider.personalityGroups[0].tags[0].label;
    selectedGroup = dataProvider.personalityGroups[0].title;
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final goalsResponse = await http.get(Uri.parse(
          '${EnvironmentConfig.instance.serverURL}/goals?position=$positionValue'));
      final actionsResponse = await http.get(Uri.parse(
          '${EnvironmentConfig.instance.serverURL}/actions?position=$positionValue'));

      if (goalsResponse.statusCode == 200 &&
          actionsResponse.statusCode == 200) {
        final List<dynamic> goalsData = json.decode(goalsResponse.body);
        final List<dynamic> actionsData = json.decode(actionsResponse.body);

        setState(() {
          _goals =
              goalsData.map((goal) => goal['goalName'].toString()).toList();
          _actions = actionsData
              .map((action) => action['actionName'].toString())
              .toList();

          _isLoading = false;
        });

        print(_goals);
        print(_actions);
      } else {
        setState(() {
          _error = 'Failed to load goals: ${goalsResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading goals: $e';
        _isLoading = false;
      });
    }
  }

  void _onGoalSelected(String? value) {
    setState(() {
      _selectedGoal = value ?? '';
      if (_selectedGoal.isNotEmpty) {
        _showActions = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToWidget(_actionsKey);
        });
      }
    });
  }

  void _checkActionsCount() {
    if (_selectedActions.length >= 3 && !_showPersonality) {
      setState(() {
        _showPersonality = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToWidget(_personalityKey);
        });
      });
    }
  }

  void handleSubmit() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    " Validate passed".blue.log();
    try {
      final response = await AppFetch.fetch(
          '/users/update-${widget.event}/${widget.id}',
          method: 'PUT',
          headers: {
            'Custom-Header': 'Value'
          },
          body: {
            'goal': {'goalName': _selectedGoal},
            'actions': _selectedActions
                .map((item) => {'actionName': item['action']})
                .toList(),
            'personalityGroup': {'title': selectedGroup, 'tag': selectedTag},
          });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          mounted) {
        print('Response data: ${response.body}');

        if (widget.event == 'match') {
          final Match newMatch = Match.fromJson(jsonDecode(response.body));
          userProvider.updateMatch(newMatch);

          showAppNotifyDraw(context,
              isPersistent: true,
              seconds: 10,
              audioUrl:
                  'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%94%D7%95%D7%93%D7%A2%D7%94%20%D7%90%D7%97%D7%A8%D7%99%20%D7%94%D7%9B%D7%A0%D7%94%20%D7%9C%D7%9E%D7%A9%D7%97%D7%A7.mp3?alt=media&token=93334f41-b284-4277-87a5-55a70cab98d8',
              audioImageUrl: 'images/eitan.png',
              title: 'הכנה למשחק',
              message: 'המשחק שלך מוכן!',
              primaryButtonLabel: 'הבנתי, תודה!',
              primaryButtonAction: '0020 , Click , I Got It In Notify',
              secondaryButtonLabel: 'לא רוצה להקשיב');
        } else {
          final Training newTraining =
              Training.fromJson(jsonDecode(response.body));
          userProvider.updateTraining(newTraining);
        }

        context.go('/dashboard/4');
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addActionField() {
    if (_selectedActions.length < maxActionFields) {
      setState(() {
        _selectedActions.add({
          'id': (_actionIdCounter++).toString(),
          'action': null,
        });
      });
    }
  }

  void _removeActionField(String id) {
    setState(() {
      _selectedActions.removeWhere((item) => item['id'] == id);
      if (_selectedActions.length < 3) {
        _showPersonality = false;
      }
    });
  }

  List<String> _getAvailableActions(String currentId) {
    final selectedActions = _selectedActions
        .where((item) => item['id'] != currentId && item['action'] != null)
        .map((item) => item['action'].toString())
        .toList();

    return _actions
        .where((action) => !selectedActions.contains(action))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final String eventTitle = widget.event == 'match' ? 'למשחק' : 'לאימון';

    if (_isLoading) {
      return AppPageLayout(
        title: 'הכנה $eventTitle',
        child: Center(
          child: Container(
            color: Colors.transparent,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      print(_error);
      return Center(child: Text('שגיאה'));
    }

    return AppPageLayout(
      title: 'הכנה $eventTitle',
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    textDirection: TextDirection.rtl, // כיוון מימין לשמאל
                    children: [
                      // הכותרת בצד ימין
                      Expanded(
                        child: AppSubtitle(
                          subTitle: 'מטרה $eventTitle',
                          verticalMargin: 0,
                          fontSize: 36,
                          fontFamily: 'Barlev',
                          textAlign: TextAlign.right,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // רכיב האודיו הקטן בצד שמאל
                      AppMiniAudioPlayer(
                        audioUrl:
                            'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%9E%D7%98%D7%A8%D7%94%20%D7%9C%D7%9E%D7%A9%D7%97%D7%A7.mp3?alt=media&token=6daf9673-84b2-4788-9869-7f36a49833a7',
                        action:
                            '0008 , Click , Mini Audio Play - Prepare Match',
                        size: 45.0,
                      ),
                    ],
                  ),
                  AppSubtitle(
                    subTitle: 'מה המטרה שלך למשחק הקרוב?',
                    isBold: false,
                    fontSize: 16,
                    verticalMargin: 0,
                  ),
                  AppAutocompleteFormField(
                    secondeyStyle: true,
                    value: _selectedGoal,
                    options: _goals,
                    onChanged: _onGoalSelected,
                    allowCustomValues: true,
                    validator: (value) {
                      if (value == null || value.toString().isEmpty) {
                        return 'נא לבחור מטרה';
                      }
                      return null;
                    },
                    customValueCreator: (String goal) {
                      setState(() {
                        _selectedGoal = goal;
                      });
                      return goal;
                    },
                  ),
                  if (_showActions) ...[
                    AppDivider(xMargin: 30),
                    AnimatedOpacity(
                      opacity: _showActions ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        key: _actionsKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textDirection: TextDirection.rtl,
                            children: [
                              // הכותרת בצד ימין
                              Expanded(
                                child: AppSubtitle(
                                  subTitle: 'פעולות $eventTitle',
                                  verticalMargin: 0,
                                  fontSize: 36,
                                  fontFamily: 'Barlev',
                                  textAlign: TextAlign.right,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // רכיב האודיו הקטן בצד שמאל
                              AppMiniAudioPlayer(
                                audioUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%A4%D7%A2%D7%95%D7%9C%D7%95%D7%AA.mp3?alt=media&token=a3cc76bb-8f71-4251-8470-b10dbb09356a',
                                action:
                                    '0009 , Click , Mini Audio Play - Actions Section',
                                size: 45.0,
                              ),
                            ],
                          ),
                          AppSubtitle(
                            subTitle:
                                ' הפעולות שאני מתחייב לעשות ויקדמו אותי למטרה?',
                            isBold: false,
                            fontSize: 16,
                            verticalMargin: 0,
                            textAlign: TextAlign.right,
                          ),
                          Column(
                            children: [
                              ..._selectedActions.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    key: ValueKey(item['id']),
                                    children: [
                                      Expanded(
                                        child: AppAutocompleteFormField(
                                          isListField: true,
                                          textStyle:
                                              const TextStyle(fontSize: 20),
                                          secondeyStyle: true,
                                          value: item['action'],
                                          options:
                                              _getAvailableActions(item['id']),
                                          onChanged: (value) {
                                            setState(() {
                                              item['action'] = value;
                                              _checkActionsCount();
                                            });
                                          },
                                          allowCustomValues: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.toString().isEmpty) {
                                              return 'נא להזין או לבחור פעולה';
                                            }
                                            return null;
                                          },
                                          customValueCreator: (String action) {
                                            setState(() {
                                              item['action'] = action;
                                            });
                                            return action;
                                          },
                                          onRemove: () {
                                            _removeActionField(item['id']);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 30),
                              GestureDetector(
                                onTap: _addActionField,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  color: AppColors.darkergrey,
                                  strokeWidth: 1,
                                  dashPattern: const [6, 4],
                                  child: Container(
                                    height: 59,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 35,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_showPersonality) ...[
                    AppDivider(xMargin: 30),
                    AnimatedOpacity(
                      opacity: _showPersonality ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        key: _personalityKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            textDirection: TextDirection.rtl,
                            children: [
                              // הכותרת בצד ימין
                              Expanded(
                                child: AppSubtitle(
                                  subTitle: 'עם איזה אופי אני נכנס $eventTitle',
                                  verticalMargin: 0,
                                  isBold: true,
                                  fontSize: 36,
                                  fontFamily: 'Barlev',
                                  textAlign: TextAlign.right,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // רכיב האודיו הקטן בצד שמאל
                              AppMiniAudioPlayer(
                                audioUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%90%D7%95%D7%A4%D7%99%20%D7%9C%D7%9E%D7%A9%D7%97%D7%A7.mp3?alt=media&token=b4cf841d-64fe-4a92-ac55-e193d431768a',
                                action:
                                    '0010 , Click , Mini Audio Play - Personality Section',
                                size: 45.0,
                              ),
                            ],
                          ),
                          AppSubtitle(
                            subTitle:
                                'בוחרים תכונה אחת מבין כל האפשריות הבאות $eventTitle',
                            isBold: false,
                            fontSize: 16,
                            verticalMargin: 0,
                            color: Colors.black54,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 10),
                          AppCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.start,
                                  children: dataProvider.personalityGroups
                                      .expand((group) =>
                                          group.tags.map((tag) => AppChoiceChip(
                                                label: tag.label,
                                                selectedValue: selectedTag,
                                                onSelected: (value) {
                                                  setState(() {
                                                    selectedTag = value;
                                                    // מוצא את הקבוצה של התגית שנבחרה
                                                    for (var g in dataProvider
                                                        .personalityGroups) {
                                                      if (g.tags.any((t) =>
                                                          t.label == value)) {
                                                        selectedGroup = g.title;
                                                        break;
                                                      }
                                                    }
                                                  });
                                                },
                                              )))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_showPersonality) ...[
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                          action: '0014 , Click , Set prepare match',
                          pHeight: 15,
                          onPressed: handleSubmit,
                          label: 'המשך >'),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
