import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_devider.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_number_selector.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';

// Controller to expose functionality to parent
class AppSliderController {
  // Will be assigned in the state class
  bool Function()? moveToNextStep;
  bool Function()? isLastStep;
  VoidCallback? completeAction;
  // Add this callback
  void Function(bool isLast)? onLastStepChanged;
}

class AppSliderWithSelect extends StatefulWidget {
  final List<JoinAction>? actionArray;
  final JoinGoal? goal;
  final double actionFontSize;
  final String personalityGroupTag;
  final VoidCallback? onComplete;
  final String completionButtonText;
  final AppSliderController? controller; // Add controller parameter
  final NumberSelectorController? personalityGroupTagController;
  final bool isMatch;
  const AppSliderWithSelect({
    super.key,
    this.goal,
    required this.actionArray,
    required this.personalityGroupTag,
    required this.isMatch,
    this.actionFontSize = 24,
    this.onComplete,
    this.completionButtonText = 'הבא',
    this.controller,
    this.personalityGroupTagController,
  });

  @override
  State<AppSliderWithSelect> createState() => _AppSliderWithSelectState();
}

class _AppSliderWithSelectState extends State<AppSliderWithSelect> {
  late String titleText;
  late String subTitleText;
  int currentStep = 0;
  int? selectedOptionIndex;

  // Helper to determine if there's a goal to display as first step
  bool get hasGoal => widget.goal != null;

  // Helper to get total steps count (actions + goal if present)
  int get totalSteps => (widget.actionArray?.length ?? 0) + (hasGoal ? 1 : 0);

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      // Assign methods to controller
      widget.controller!.moveToNextStep = _handleNextStep;
      widget.controller!.isLastStep = _isLastStep;
      widget.controller!.completeAction = _handleComplete;
    }

    // Set initial selection based on current performed value
    _setSelectedIndexFromPerformedValue(_getCurrentPerformedValue());
  }

  // Helper to set selectedOptionIndex based on performed value
  void _setSelectedIndexFromPerformedValue(double? performed) {
    if (performed == 1) {
      selectedOptionIndex = 2;
    } else if (performed == 0.5) {
      selectedOptionIndex = 1;
    } else if (performed == 0) {
      selectedOptionIndex = 0;
    } else {
      selectedOptionIndex = null;
    }
  }

  // Helper to get performed value for current step
  double? _getCurrentPerformedValue() {
    if (hasGoal && currentStep == 0) {
      return widget.goal?.performed;
    } else {
      final actionIndex = hasGoal ? currentStep - 1 : currentStep;
      return widget.actionArray?[actionIndex].performed;
    }
  }

  bool _isLastStep() {
    return currentStep >= totalSteps;
  }

  // Helper to get current action name
  String _getCurrentActionName() {
    if (hasGoal && currentStep == 0) {
      return widget.goal!.goalName ?? "יעד המשחק";
    } else {
      final actionIndex = hasGoal ? currentStep - 1 : currentStep;
      return widget.actionArray![actionIndex].actionName;
    }
  }

  String _getCurrentTitleName() {
    if (hasGoal && currentStep == 0) {
      return 'מטרה שתכננת ${widget.isMatch ? 'למשחק' : 'לאימון'}';
    } else if (!_isLastStep()) {
      return 'פעולות שתכננו ${widget.isMatch ? 'למשחק' : 'לאימון'}';
    } else {
      return 'עד כמה עמדת ביעד האופי?';
    }
  }

  String _getCurrentSubTitleName() {
    if (hasGoal && currentStep == 0) {
      return 'ביצעת את המטרה שתכננת?';
    } else if (!_isLastStep()) {
      return 'ביצעת את הפעולות שתכננת?';
    } else {
      return '';
    }
  }

  // Helper to update current action performed value
  void _updatePerformedValue(int? index) {
    double value = index == 2 ? 1.0 : (index == 1 ? 0.5 : 0.0);

    if (hasGoal && currentStep == 0) {
      widget.goal!.performed = value;
    } else {
      final actionIndex = hasGoal ? currentStep - 1 : currentStep;
      widget.actionArray![actionIndex].performed = value;
    }
  }

  void _handleComplete() {
    widget.onComplete?.call();
  }

  // Returns true if successfully moved to next step, false if validation failed
  bool _handleNextStep() {
    if (_isLastStep()) {
      return true; // Already at last step
    }

    if (selectedOptionIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('נא לבחור פעולה',
              style: TextStyle(fontSize: 20, color: Colors.red))));
      return false;
    }

    setState(() {
      currentStep++;
      // If we're advancing to a step with existing performed value, initialize the selection
      _setSelectedIndexFromPerformedValue(_getCurrentPerformedValue());
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    "${widget.actionArray?.length}".green.log();
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: AppSubtitle(
            subTitle: _getCurrentTitleName(),
            textAlign: TextAlign.start,
            verticalMargin: 8,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AppSubtitle(
              subTitle: _getCurrentSubTitleName(),
              textAlign: TextAlign.start,
              verticalMargin: 0,
              isBold: false,
              fontSize: 14),
        ),
        SizedBox(height: 16),
        AppCard(
          border: Border.all(color: AppColors.borderGrey, width: 1),
          padding: EdgeInsets.all(16),
          elevation: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isLastStep()) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 100),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        _getCurrentActionName(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.actionFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),
                AppDivider(),
                AppToggleButtons(
                  screenWidth: screenWidth - 64,
                  isRounded: true,
                  labels: const ["לא בוצע", "חלקי", "בוצע"],
                  selectedIndex: selectedOptionIndex,
                  isSelected: [false, false, false],
                  onPressed: (int index) {
                    setState(() {
                      if (selectedOptionIndex == index) {
                        selectedOptionIndex = null;
                        _updatePerformedValue(null); // Reset to 0
                      } else {
                        selectedOptionIndex = index;
                        _updatePerformedValue(index);
                      }
                    });
                  },
                  buttonsPadding: const EdgeInsets.symmetric(vertical: 12),
                  fontSize: 16,
                ),
              ],
              if (_isLastStep())
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    spacing: 15,
                    children: [
                      Text(
                        "יעד האופי שבחרת",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      IntrinsicWidth(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.primary,
                          ),
                          child: Text(
                            widget.personalityGroupTag,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      AppDivider(),
                      NumberSelector(
                          sizeMultiplier: 0.82,
                          controller: widget.personalityGroupTagController,
                          fealList: FEEEL_LIST_2)
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalSteps,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= currentStep ? Colors.black : Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                  onTap: () => {
                    setState(() {
                      if (index <= currentStep) {
                        currentStep = index;
                        _setSelectedIndexFromPerformedValue(
                            _getCurrentPerformedValue());
                        widget.controller?.onLastStepChanged
                            ?.call(_isLastStep());
                      }
                    })
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
