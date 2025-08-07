import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class NumberSelectorController extends ValueNotifier<int?> {
  NumberSelectorController({int? initialValue}) : super(initialValue);
}

class NumberSelector extends StatefulWidget {
  final NumberSelectorController? controller;
  final List<String> fealList;
  final double? sizeMultiplier;
  final double? numberFontSize;
  final double? textFontSize;
  final double? itemWidth;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? borderRadius;

  const NumberSelector({
    super.key,
    this.sizeMultiplier = 1.0,
    this.controller,
    this.fealList = const [],
    this.numberFontSize,
    this.textFontSize,
    this.itemWidth,
    this.verticalPadding,
    this.horizontalPadding,
    this.borderRadius,
  });

  @override
  NumberSelectorState createState() => NumberSelectorState();
}

class NumberSelectorState extends State<NumberSelector> {
  late NumberSelectorController _controller;

  // Default sizes
  final double _defaultNumberFontSize = 40.0;
  final double _defaultTextFontSize = 15.0;
  final double _defaultItemWidth = 54.0;
  final double _defaultVerticalPadding = 10.0;
  final double _defaultHorizontalPadding = 4.0;
  final double _defaultBorderRadius = 4.0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? NumberSelectorController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _selectFeeling(int value) {
    _controller.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final multiplier = widget.sizeMultiplier ?? 1.0;
    final numberSize =
        (widget.numberFontSize ?? _defaultNumberFontSize) * multiplier;
    final textSize = (widget.textFontSize ?? _defaultTextFontSize) * multiplier;
    final itemWidth = (widget.itemWidth ?? _defaultItemWidth) * multiplier;
    final vPadding =
        (widget.verticalPadding ?? _defaultVerticalPadding) * multiplier;
    final hPadding =
        (widget.horizontalPadding ?? _defaultHorizontalPadding) * multiplier;
    final borderRadius =
        (widget.borderRadius ?? _defaultBorderRadius) * multiplier;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int value = index + 1;
        bool isSelected = _controller.value == value;

        return GestureDetector(
          onTap: () => _selectFeeling(value),
          child: Container(
            decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                    width: 1 * multiplier, color: AppColors.borderGrey),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(index == 4 ? borderRadius : 0),
                    bottomLeft: Radius.circular(index == 4 ? borderRadius : 0),
                    topRight: Radius.circular(index == 0 ? borderRadius : 0),
                    bottomRight:
                        Radius.circular(index == 0 ? borderRadius : 0))),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: vPadding, horizontal: hPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTitle(
                      title: value.toString(),
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: numberSize,
                      lineHeight: 1,
                      verticalMargin: 0,
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: Text(widget.fealList[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: textSize,
                            height: 1,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w400,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
