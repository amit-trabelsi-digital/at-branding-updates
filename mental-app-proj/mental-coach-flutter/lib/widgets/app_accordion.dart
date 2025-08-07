import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class Accordion extends StatefulWidget {
  final String? title;
  final Widget child;
  final bool softTitleStyle;
  final bool useCard;
  final EdgeInsets padding;
  final Widget? customeHeader;
  final double iconSize;
  final EdgeInsets? titlePadding;
  final double? minVerticalPadding;
  final double? minTileHeight;
  final bool isExpanded;
  const Accordion(
      {super.key,
      this.title,
      required this.child,
      this.softTitleStyle = false,
      this.customeHeader,
      this.iconSize = 24,
      this.titlePadding =
          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      this.useCard = true,
      this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      this.minVerticalPadding,
      this.minTileHeight,
      this.isExpanded = true});

  @override
  AccordionState createState() => AccordionState();
}

class AccordionState extends State<Accordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        ListTile(
          minTileHeight: widget.minTileHeight,
          minVerticalPadding: widget.minVerticalPadding,
          title: widget.customeHeader ??
              (!widget.softTitleStyle
                  ? AppTitle(
                      title: widget.title ?? 'הכנס מידע',
                      verticalMargin: 0,
                      fontSize: 38,
                    )
                  : AppSubtitle(
                      subTitle: widget.title ?? 'הכנס מידע',
                      textAlign: TextAlign.start,
                      verticalMargin: 0,
                    )),
          trailing: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0, // 180° rotation
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Image.asset(
                'icons/arrow-down-icon.png', // Active state image
                width: widget.iconSize,
                height: widget.iconSize,
              )),
          contentPadding: widget.titlePadding,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        AnimatedCrossFade(
          firstChild: SizedBox.shrink(),
          secondChild: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 100),
        ),
      ],
    );

    return widget.useCard
        ? AppCard(
            elevation: 2,
            child: content,
          )
        : Container(
            child: content,
          );
  }
}
