import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_accordion.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';

class AppMatchNotifyDraw extends StatefulWidget {
  final Match match;
  final OverlayEntry overlayEntry;

  const AppMatchNotifyDraw(
      {required this.match, required this.overlayEntry, super.key});

  @override
  AppMatchNotifyDrawState createState() => AppMatchNotifyDrawState();
}

class AppMatchNotifyDrawState extends State<AppMatchNotifyDraw>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Constants for styling
  static const double _defaultFontSize = 18.0;
  static const double _titleFontSize = 20.0;
  static const double _sectionSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Reusable information card widget
  Widget _buildInfoCard(String title, {double? performed}) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        softShadow: true,
        borderRadius: 10,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: _defaultFontSize),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (performed != null)
                AppCard(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    borderRadius: 10,
                    child: Center(
                      child: Text(
                        performed == 1
                            ? 'בוצע'
                            : performed == 0.5
                                ? 'חלקי'
                                : 'לא בוצע',
                        style: TextStyle(fontSize: 18),
                      ),
                    ))
            ]),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return AppSubtitle(
      height: 0.8,
      color: AppColors.darkergrey,
      subTitle: title,
      fontSize: _titleFontSize,
      textAlign: TextAlign.start,
      verticalMargin: 0,
      isBold: true,
    );
  }

  // Helper for vertical spacing
  Widget _verticalSpace([double height = _sectionSpacing]) =>
      SizedBox(height: height);

  // Helper method to build action items
  Widget _buildActionItem(JoinAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: _buildInfoCard(action.actionName, performed: action.performed),
    );
  }

  Widget _devider({double height = 4}) {
    return Container(
        width: double.infinity, height: height, color: AppColors.grey);
  }

  @override
  Widget build(BuildContext context) {
    // final formattedTime = DateFormat('HH:mm').format(widget.match.date);
    final formattedDate = formatDateToHebrew(widget.match.date);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x742b2d35), Color(0xff2b2d36)],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.84,
              color: Colors.white,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'מה היה לנו?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              iconSize: 25,
                              padding: EdgeInsets.all(0),
                              alignment: Alignment.centerLeft,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                if (widget.overlayEntry.mounted) {
                                  widget.overlayEntry.remove();
                                }
                              },
                            ),
                          ],
                        ),
                        _devider(),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  height: 45,
                                  width: 190,
                                ),
                                Positioned(
                                  top: 22,
                                  child: Text(
                                      '${widget.match.awayTeam.name} - ${widget.match.homeTeam.name}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                                Positioned(
                                  child: AppLabel(
                                    title: formattedDate,
                                    subTitle: 'משחק חוץ',
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Text('תוצאה'),
                                  Text(widget.match.matchResult ?? 'אין'),
                                ],
                              ),
                            ))
                          ],
                        ),
                        SizedBox(height: 17),
                        _devider(),
                        Accordion(
                            padding: EdgeInsets.all(3),
                            useCard: false,
                            softTitleStyle: true,
                            minVerticalPadding: 0,
                            title: 'איך הייתי',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildSectionTitle('היעד שלי'),
                                _verticalSpace(5),
                                _buildInfoCard(
                                    widget.match.goal?.goalName ?? 'אין מידע',
                                    performed: widget.match.goal?.performed),
                                _verticalSpace(),
                                _devider(),
                                _buildSectionTitle('פעולות'),
                                _verticalSpace(),
                                ...(widget.match.actions
                                        ?.map(_buildActionItem)
                                        .toList() ??
                                    []),
                                _verticalSpace(),
                                _devider(),
                                _buildSectionTitle('יעד אופי'),
                                _verticalSpace(3),
                                _buildInfoCard(
                                    widget.match.personalityGroup?.tag ??
                                        'אין מידע',
                                    performed: widget
                                        .match.personalityGroup?.performed),
                                _verticalSpace(),
                              ],
                            )),
                        _devider(),
                        Accordion(
                            padding: EdgeInsets.all(3),
                            useCard: false,
                            softTitleStyle: true,
                            minVerticalPadding: 0,
                            title: 'הערות לעצמי',
                            child: Column(children: [
                              _verticalSpace(5),
                              AppCard(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 20),
                                  borderRadius: 10,
                                  child: Row(
                                    spacing: 15,
                                    children: [
                                      Image.asset('icons/file-info-icon.png'),
                                      Expanded(
                                        child: Text(
                                          widget.match.note ?? 'אין הערות',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  )),
                              _verticalSpace(),
                            ])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
