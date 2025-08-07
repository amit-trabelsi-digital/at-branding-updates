import 'package:color_simp/color_simp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_auto_complete.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout_with_nav.dart';
import 'package:mental_coach_flutter_firebase/widgets/players/app_video_player.dart';
import 'package:provider/provider.dart';

class SetProfilePage extends StatefulWidget {
  const SetProfilePage({super.key});

  @override
  State<SetProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<SetProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final double size = 20;
  static const int defaultIntHex = 0xFFFFFFFF;
  static const String defaulttHex = '#ffffffff';
  int _selectedIndex = 1; // Default to "ימנית"
  bool _isLoading = false; // Add loading state variable
  // Dropdown data
  // List<dynamic> _leagues = [];
  // List<dynamic> _teams = [];

  // User States
  dynamic _selectedLeague;
  dynamic _selectedTeam;
  dynamic _selectedUserTeam;
  dynamic _selectedUserLeague;
  dynamic _selectedPosition;
  String? firstName;
  String? lastName;
  String? nickName;
  String? playerNumber;

  TextEditingController firstNamecontroller = TextEditingController();
  TextEditingController lastNamecontroller = TextEditingController();
  TextEditingController nickNamecontroller = TextEditingController();
  TextEditingController playerNumberController = TextEditingController();

  List<Color> selectedColors = [
    Color(defaultIntHex),
    Color(defaultIntHex),
    Color(defaultIntHex),
  ];

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeUserData();
    });
  }

  void initializeUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // Safe access to nested properties
    if (kDebugMode &&
        dataProvider.generalData != null &&
        dataProvider.generalData['profileAudioFile'] != null &&
        dataProvider.generalData['profileAudioFile']['fileData'] != null) {
      "Print ==> ${dataProvider.generalData['profileAudioFile']['fileData']['path']}"
          .green
          .log();
    }

    final user = userProvider.user;
    if (user != null) {
      if (kDebugMode) {
        "COLOR TEST".green.log();
        print(flutterColorToHex(Color(0xFFFF33FF)));
      }

      setState(() {
        firstNamecontroller.text = user.firstName ?? '';
        lastNamecontroller.text = user.lastName ?? '';
        nickNamecontroller.text = user.nickName ?? '';
        playerNumberController.text = user.playerNumber ?? '';
        _selectedIndex = user.strongLeg == 'right' ? 0 : 1;
        _selectedLeague = user.league?.name;
        _selectedTeam = user.team?.name;
        _selectedUserLeague = user.userLeague?.name;
        _selectedUserTeam = user.userTeam?.name;
        _selectedPosition = getLabelByValue(positions, user.position ?? 'ST');
        selectedColors = [
          hexToFlutterColor(
              user.selectedTeamColor?.hex1 ?? user.team?.hex1 ?? defaulttHex),
          hexToFlutterColor(
              user.selectedTeamColor?.hex2 ?? user.team?.hex2 ?? defaulttHex),
          hexToFlutterColor(
              user.selectedTeamColor?.hex3 ?? user.team?.hex3 ?? defaulttHex)
        ];
      });
    }
  }

  void _pickColor(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('בחר צבע'),
          content: SingleChildScrollView(
            child: BlockPicker(
              availableColors: footballTeamColors,
              pickerColor: selectedColors[index],
              onColorChanged: (color) {
                setState(() {
                  selectedColors[index] = color;
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('סגור'),
            ),
          ],
        );
      },
    );
  }

  void handleSubmit() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true; // Set loading to true when submission starts
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var selectedTeamColor = SelectedTeamColor(
        hex1: flutterColorToHex(selectedColors[0]),
        hex2: flutterColorToHex(selectedColors[1]),
        hex3: flutterColorToHex(selectedColors[2]));

    try {
      final response =
          await AppFetch.fetch('/users/update', method: 'PUT', headers: {
        'Custom-Header': 'Value'
      }, body: {
        'firstName': firstName,
        'lastName': lastName,
        'nickName': nickName,
        'playerNumber': playerNumber,
        'strongLeg': _selectedIndex == 0 ? 'right' : 'left',
        'league': _selectedLeague != null
            ? getIdByKeyValue(dataProvider.leagues, _selectedLeague)
            : null, // יחזיר null שאין קבוצה כזו,
        'team': _selectedTeam != null
            ? getIdByKeyValue(dataProvider.teams, _selectedTeam)
            : null, // יחזיר null שאין קבוצה כזו,
        'userTeam':
            _selectedUserTeam != null ? {'name': _selectedUserTeam} : null,
        'userLeague':
            _selectedUserLeague != null ? {'name': _selectedUserLeague} : null,
        'position': getValueByLabel(positions, _selectedPosition),
        'selectedTeamColor': selectedTeamColor,
        'setProfileComplete': true,
      });

      if (response.statusCode == 200 && mounted) {
        userProvider.refreshUserData();
        context.push('/set-goals-profile');
        print('Response data: ${response.body}');
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Set loading to false when done
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Provider.of<UserProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: AppPageLayout(
        title: 'פרופיל',
        // optionalWidget: AppButton(
        //   borderRadius: 25,
        //   action: '0015 , Click , back',
        //   fontSize: 15,
        //   icon: Icon(
        //     color: Colors.white,
        //     size: 10,
        //     Icons.chevron_right_sharp,
        //   ),
        //   pHeight: 4,
        //   onPressed: () {
        //     context.pop();
        //   },
        //   label: 'חזרה',
        // ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the container
                    borderRadius: BorderRadius.circular(
                        20.0), // Border radius for rounded corners
                    boxShadow: [AppShadows.defaultShadow],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppSubtitle(subTitle: 'מסר חשוב לפני שמתחילים'),
                        SizedBox(height: 10),
                        VideoWidget(
                            videoUrl: Uri.parse(
                                'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%A4%D7%A8%D7%95%D7%A4%D7%99%D7%9C%20%D7%9E%D7%A8%D7%95%D7%91%D7%A2.mp4?alt=media&token=d67a660d-c197-42d6-8d58-26df165ef46f'),
                            thumbnailUrl:
                                'https://firebasestorage.googleapis.com/v0/b/mental-coach-c7f94.firebasestorage.app/o/welcome-videos%2F%D7%A4%D7%A8%D7%95%D7%A4%D7%99%D7%9C%20%D7%9E%D7%A8%D7%95%D7%91%D7%A2.gif?alt=media&token=3f757e3e-d0f9-4b2e-b6a5-9da64022c30f',
                            action: '0001 , Click , Profile Video Play'),
                        // AudioWidget(
                        //     audioUrl: UrlSource(dataProvider
                        //                 .generalData['profileAudioFile']
                        //             ?['fileData']?['path'] ??
                        //         'https://example.com/default-audio.mp3'), // Fallback URL if path is missing
                        //     imageUrl: 'images/eitan.png'),
                        SizedBox(height: 10),
                        AppDivider(),
                        AppFormField(
                          title: 'שם פרטי',
                          subtitle: 'כדי שנדע איך לקרוא לך',
                          validationMessage: 'נא למלא שם פרטי',
                          controller: firstNamecontroller,
                        ),
                        SizedBox(height: size),
                        AppFormField(
                          title: 'שם משפחה',
                          subtitle: 'כדי שנדע איך לקרוא לך',
                          validationMessage: 'נא למלא שם משפחה',
                          controller: lastNamecontroller,
                        ),
                        SizedBox(height: size),
                        AppFormField(
                          title: 'כינוי',
                          subtitle: 'לא חובה, רק אם יש',
                          controller: nickNamecontroller,
                        ),
                        SizedBox(height: size),
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: const Text(
                            'רגל חזקה',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        AppToggleButtons(
                          isSelected: [
                            _selectedIndex == 0,
                            _selectedIndex == 1
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          screenWidth: screenWidth,
                          labels: ['ימנית', 'שמאלית'],
                        ),
                        SizedBox(height: size),

                        // Position Dropdown
                        AppAutocompleteFormField<String>(
                          title: 'עמדה',
                          value: _selectedPosition,
                          options: positions.map((league) {
                            return league.label;
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPosition = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'נא לבחור עמדה';
                            }
                            return null;
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                        SizedBox(height: size),
                        // Leagues Dropdown
                        AppAutocompleteFormField<String>(
                          allowCustomValues: true,
                          title: 'ליגה',
                          value: _selectedLeague ?? _selectedUserLeague,
                          options: dataProvider.leagues.map((league) {
                            return league.name;
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                _selectedUserLeague = null;
                                _selectedLeague = value;
                              }
                            });
                          },
                          customValueCreator: (String leagueName) {
                            "Custom Value league: $leagueName".green.log();
                            setState(() {
                              _selectedUserLeague = leagueName;
                              _selectedLeague = null;
                            });
                            return leagueName;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'נא לבחור ליגה';
                            }
                            return null;
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                        SizedBox(height: size),

                        // Teams Dropdown
                        AppAutocompleteFormField<String>(
                          title: 'קבוצה',
                          value: _selectedTeam ?? _selectedUserTeam,
                          allowCustomValues: true,
                          options: dataProvider.teams
                              .map((team) {
                                return team.name ?? '';
                              })
                              .where((name) => name.isNotEmpty)
                              .toList(),
                          customValueCreator: (String teamName) {
                            setState(() {
                              _selectedUserTeam = teamName;
                              _selectedTeam = null;
                            });
                            return teamName;
                          },
                          onChanged: (value) {
                            "onChange: $value".green.log();

                            setState(() {
                              if (value != null) {
                                _selectedUserTeam = null;
                                _selectedTeam = value;
                                final selectedTeamData = dataProvider.teams
                                    .firstWhere((team) => team.name == value);

                                if (selectedTeamData.name == value) {
                                  selectedColors = [
                                    hexToFlutterColor(
                                        selectedTeamData.hex1 ?? defaulttHex),
                                    hexToFlutterColor(
                                        selectedTeamData.hex2 ?? defaulttHex),
                                    hexToFlutterColor(
                                        selectedTeamData.hex3 ?? defaulttHex),
                                  ];
                                }
                              }
                            });
                          },
                          validator: (value) {
                            "Selected Team: $value".green.log();
                            if (value == null) {
                              return 'נא לבחור קבוצה';
                            }
                            return null;
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),

                        SizedBox(height: size),
                        AppFormField(
                          numbersOnly: true,
                          title: 'מספר לחולצה',
                          subtitle: 'עד שתי ספרות',
                          controller: playerNumberController,
                        ),
                        SizedBox(height: size),
                        AppLabel(
                            title: 'צבעים לחולצה', subTitle: 'בוחרים שלושה'),
                        SizedBox(height: 30),
                        Row(
                          children:
                              List.generate(selectedColors.length, (index) {
                            return GestureDetector(
                              onTap: () => _pickColor(context, index),
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: selectedColors[index],
                                    border: Border.all(
                                        color: AppColors.borderGrey,
                                        width: 0.5)),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    action: '0007 , Click , Save Profile',
                    pHeight: 15,
                    isLoading:
                        _isLoading, // Pass the loading state to the button
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          firstName = firstNamecontroller.text;
                          lastName = lastNamecontroller.text;
                          nickName = nickNamecontroller.text;
                          playerNumber = playerNumberController.text;
                        });
                        handleSubmit();
                      }
                    },
                    label: 'שמירת פרופיל והמשך',
                  ),
                ),
                SizedBox(height: size * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
