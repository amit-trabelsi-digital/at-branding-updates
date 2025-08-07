import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/screens/main/cases_and_reactions.dart';
import 'package:mental_coach_flutter_firebase/screens/main/dashboard.dart';
import 'package:mental_coach_flutter_firebase/screens/main/profile.dart';
import 'package:mental_coach_flutter_firebase/screens/main/schedule_match.dart';
import 'package:mental_coach_flutter_firebase/screens/main/training.dart';
import 'package:mental_coach_flutter_firebase/screens/main/mental_profile_page.dart';
import 'package:mental_coach_flutter_firebase/screens/support/support_dialog.dart';

import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/page_layout.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';

int _parseIndex(String value) {
  try {
    "${int.parse(value)}".green.log();
    return int.parse(value);
  } catch (e) {
    return 0; // Default to first tab if parsing fails
  }
}

class MainScreen extends StatefulWidget {
  final String? choosenIndex;
  const MainScreen({super.key, this.choosenIndex});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to the dashboard tab
  bool _isVisible = true; // Controls visibility of the navigation bar
  final int _menuItemFontSize = 12;
  bool _isGoalsDialogOpen = false; // מעקב אחר מצב הפופאפ
  String _apiVersion = ''; // גרסת ה-API

  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _parseIndex(widget.choosenIndex ?? '0');
    _fetchApiVersion();
  }

  void _fetchApiVersion() async {
    try {
      final versionData = await getApiVersion();
      if (mounted) {
        setState(() {
          _apiVersion = versionData['version'] ?? '';
        });
      }
    } catch (e) {
      'Error fetching API version: $e'.red.log();
    }
  }

  String _getCurrentPageName() {
    switch (_currentIndex) {
      case 0:
        return 'דשבורד';
      case 1:
        return 'פרופיל שחקן';
      case 2:
        return 'מקרים ותגובות';
      case 3:
        return 'יעדים';
      case 4:
        return 'תוכנית אימון';
      case 5:
        return 'הפרופיל המנטלי שלי';
      default:
        return 'דף ראשי';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    // final String totalScore = userProvider.user?.totalScore.toString() ?? '';

    // Move the pages list here where context is available
    // בניית השם המלא של המשתמש
    final String firstName = userProvider.user?.firstName ?? '';
    final String lastName = userProvider.user?.lastName ?? '';
    final String fullName = '$firstName $lastName'.trim();

    final dashboardPage = PageLayout(
      title: _currentIndex == 0 && fullName.isNotEmpty ? fullName : '',
      child: DashboardPage(),
    );

    final List<Widget> pages = [
      dashboardPage,
      PageLayout(
        title: 'שלום',
        optionalWidget: AppButton(
          action: '0015 , Click , edit profile',
          fontSize: 15,
          borderRadius: 25,
          icon: const Icon(
            color: Colors.white,
            size: 20,
            Icons.exit_to_app,
          ),
          pHeight: 4,
          onPressed: () {
            userProvider.signOut(context);
          },
          label: 'התנתקות',
        ),
        child: ProfilePage(),
      ),
      const CaseAndReactions(),
      const ScheduleMatchPage(),
      const TrainingScreen(),
      const MentalProfilePage(), // הוספת העמוד החדש
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.appBG, Color(0xFFFAFAFA)],
            stops: [0.5, 0.5],
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                bool isScrollable =
                    scrollNotification.metrics.maxScrollExtent > 0;

                if (!isScrollable) {
                  if (!_isVisible) {
                    setState(() {
                      _isVisible = true;
                    });
                  }
                  return true;
                }

                if (scrollNotification is ScrollUpdateNotification) {
                  if (scrollNotification.scrollDelta! > 0) {
                    if (_isVisible) {
                      setState(() {
                        _isVisible = false;
                      });
                    }
                  } else if (scrollNotification.scrollDelta! < 0) {
                    if (!_isVisible) {
                      setState(() {
                        _isVisible = true;
                      });
                    }
                  }
                }
                return true;
              },
              child: pages[_currentIndex],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3,
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            right: _currentIndex *
                                (MediaQuery.of(context).size.width / 5),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: (MediaQuery.of(context).size.width / 5),
                              height: 3,
                              color: _currentIndex == 2
                                  ? Colors.transparent
                                  : AppColors.getSelectedColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 110,
                          padding: EdgeInsets.only(
                              bottom: 5 + MediaQuery.of(context).padding.bottom,
                              top: 15),
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildItemWithSvg(context, 0,
                                        'icons/dashboard2.svg', 'דשבורד'),
                                    _buildItem(context, 1, Icons.person,
                                        'פרופיל שחקן'),
                                    const Expanded(
                                        child: SizedBox(
                                            width:
                                                100)), // Spacer to center the middle button
                                    _buildItemWithSvg(
                                        context,
                                        4,
                                        'icons/calendar-vector.svg',
                                        'תוכנית אימון'),
                                    _buildPopupMenu(context, _currentIndex,
                                        Icons.more_vert, 'עוד'),
                                  ],
                                ),
                              ),
                              if (_apiVersion.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    'API v$_apiVersion',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -30,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: _buildCenterButton(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final dynamic currentEvent = userProvider.openEvent;

    // בדיקה אם יש משחק פתוח עם הכנה
    bool isGoalsButtonEnabled = false;
    if (currentEvent != null && currentEvent is Match && currentEvent.isOpen) {
      final hasPreparation = !hasEmptyGoalAndAction(currentEvent);
      isGoalsButtonEnabled = hasPreparation;
    }

    return GestureDetector(
      onTap: isGoalsButtonEnabled
          ? () {
              _showGoalsDialog(context, (index) {
                setState(() {
                  _currentIndex = index;
                });
              });
            }
          : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color:
              isGoalsButtonEnabled ? AppColors.primary : Colors.grey.shade400,
          shape: BoxShape.circle,
          border: (_currentIndex == 1 || _isGoalsDialogOpen)
              ? Border.all(color: Colors.white, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: (isGoalsButtonEnabled ? Colors.black : Colors.grey)
                  .withAlpha(76), // 0.3 opacity
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // שימוש
            SvgPicture.asset(
              'icons/target.svg',
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'פתק המטרות',
              style: TextStyle(
                color:
                    isGoalsButtonEnabled ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalsDialog(BuildContext context, Function(int) onTap) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dynamic currentEvent = userProvider.openEvent;

    // ---- START DEBUG LOGS ----
    '--- DEBUG: _showGoalsDialog ---'.log();
    if (currentEvent == null) {
      'currentEvent is NULL'.log();
    } else {
      'currentEvent type: ${currentEvent.runtimeType}'.log();
      'currentEvent.goal: ${currentEvent.goal}'.log();
      'currentEvent.goal?.goalName: ${currentEvent.goal?.goalName}'.log();
      'currentEvent.actions: ${currentEvent.actions}'.log();
      if (currentEvent.actions != null && currentEvent.actions.isNotEmpty) {
        currentEvent.actions.asMap().forEach((index, action) {
          'currentEvent.actions[$index].actionName: ${action.actionName}'.log();
        });
      } else {
        'currentEvent.actions is NULL or EMPTY'.log();
      }
      'currentEvent.personalityGroup: ${currentEvent.personalityGroup}'.log();
      'currentEvent.personalityGroup?.tag: ${currentEvent.personalityGroup?.tag}'
          .log();
    }
    '--- END DEBUG LOGS ---'.log();
    // ---- END DEBUG LOGS ----

    setState(() {
      _isGoalsDialogOpen = true;
    });

    showDialog(
      context: context,
      barrierColor: Colors.black45, // רקע שקוף
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.black87,
            insetPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 100),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'פתק המטרות',
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Barlev',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isGoalsDialogOpen = false;
                            });
                            Navigator.of(context).pop();
                            onTap(0);
                          },
                        ),
                      ],
                    ),
                    const AppDivider(
                      xMargin: 0,
                      height: 2,
                      customColor: AppColors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'מטרה למשחק',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25), // 0.1 opacity
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(currentEvent?.goal?.goalName ?? 'אין מטרה'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'פעולות',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (currentEvent?.actions != null &&
                        currentEvent.actions.isNotEmpty)
                      ...currentEvent.actions
                          .map<Widget>((action) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildActionItem(context,
                                    action.actionName ?? 'פעולה ללא שם'),
                              ))
                          .toList()
                    else
                      _buildActionItem(context, 'אין פעולות'),
                    const SizedBox(height: 20),
                    const Text(
                      'אופי',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionItem(
                        context,
                        currentEvent?.personalityGroup?.tag ??
                            'אין מידע על אופי'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isGoalsDialogOpen = false;
      });
    });
  }

  Widget _buildActionItem(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // 0.1 opacity
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(text),
    );
  }

  Widget _buildItem(
      BuildContext context, int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              Text(
                label,
                style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: _menuItemFontSize.toDouble()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemWithSvg(
      BuildContext context, int index, String svgPath, String label) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // שימוש
              SvgPicture.asset(
                svgPath,
                colorFilter: isSelected
                    ? const ColorFilter.mode(Colors.black, BlendMode.srcIn)
                    : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                width: 24,
                height: 24,
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: _menuItemFontSize.toDouble(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
      BuildContext context, int currentIndex, IconData icon, String label) {
    // bool isSelected = _currentIndex == index; // This might not be relevant for a popup menu
    // We use currentIndex to decide if the "עוד" button itself should be highlighted if one of its child pages is active.
    // For simplicity, we'll keep it grey unless a specific design for highlighting "More" is requested.
    bool isMoreSectionActive = currentIndex == 2 ||
        currentIndex == 4 ||
        currentIndex == 5; // הוספת אינדקס 5

    return Expanded(
      child: PopupMenuButton<String>(
        onSelected: (String result) {
          // Handle menu item selection
          'Selected: $result'.log();
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          switch (result) {
            case 'cases_reactions':
              // context.push('/cases-and-reactions'); // Old navigation
              onTap(2); // Navigate to CaseAndReactions within MainScreen
              break;
            case 'training_plan':
              // context.push('/training-plan'); // Old navigation
              onTap(
                  4); // Navigate to TrainingPage within MainScreen (new index)
              break;
            case 'schedule_match':
              // context.push('/training-plan'); // Old navigation
              onTap(
                  3); // Navigate to TrainingPage within MainScreen (new index)
              break;
            case 'mental_profile':
              onTap(5); // Navigate to MentalProfilePage
              break;
            case 'edit_profile':
              context.push('/set-profile'); // Navigates to the SetProfilePage
              break;
            case 'edit_goals':
              context.push(
                  '/set-goals-profile'); // Navigates to the GoalsProfilePage
              break;
            case 'support':
              // פתיחת דיאלוג התמיכה
              String currentPage = _getCurrentPageName();
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => SupportDialog(
                  currentPage: currentPage,
                ),
              );
              break;
            case 'logout':
              userProvider.signOut(context);
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'cases_reactions',
            child: Text('מקרים ותגובות'),
          ),
          const PopupMenuItem<String>(
            value: 'training_plan',
            child: Text('תוכנית אימון'),
          ),
          const PopupMenuItem<String>(
            value: 'schedule_match',
            child: Text('יומן משחקים'),
          ),
          const PopupMenuItem<String>(
            value: 'mental_profile',
            child: Text('הפרופיל המנטלי שלי'),
          ),
          const PopupMenuItem<String>(
            value: 'edit_profile',
            child: Text('עריכת פרופיל'),
          ),
          const PopupMenuItem<String>(
            value: 'edit_goals',
            child: Text('עריכת יעדים'),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'support',
            child: Row(
              children: [
                Icon(Icons.support_agent, size: 20),
                SizedBox(width: 8),
                Text('צריך עזרה?'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'logout',
            child: Text('התנתקות'),
          ),
          if (_apiVersion.isNotEmpty)
          PopupMenuItem<String>(
            value: 'version',
            child: Text(
                                    'API v$_apiVersion', 
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
          ),
        ],
        child: Container(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isMoreSectionActive
                    ? Colors.black
                    : Colors.grey, // Icon color for the popup menu button
              ),
              Text(
                label,
                style: TextStyle(
                  color: isMoreSectionActive ? Colors.black : Colors.grey,
                  fontWeight:
                      isMoreSectionActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: _menuItemFontSize.toDouble(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
