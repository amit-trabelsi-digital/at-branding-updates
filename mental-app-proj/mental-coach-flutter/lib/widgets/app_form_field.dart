import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_label.dart';

class AppFormField extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? validationMessage;
  final TextEditingController controller;
  final bool isTextArea;
  final String? textHint;
  final int minLines;
  final bool numbersOnly;
  final bool isPassword;
  final double borderRadius;
  final double fieldHeight;
  final bool allowWrapLabel;
  final int? maxLength;

  const AppFormField({
    super.key,
    required this.controller,
    this.title,
    this.textHint,
    this.subtitle,
    this.validationMessage,
    this.isTextArea = false,
    this.minLines = 3,
    this.numbersOnly = false,
    this.isPassword = false,
    this.borderRadius = 2.0,
    this.fieldHeight = 7.0,
    this.allowWrapLabel = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (title != null &&
              title!.isNotEmpty &&
              subtitle != null &&
              subtitle!.isNotEmpty) ...[
            AppLabel(
              title: title!,
              subTitle: subtitle!,
              allowWrap: allowWrapLabel,
            ),
            SizedBox(height: allowWrapLabel ? 8 : 2),
          ],
          TextFormField(
            controller: controller,
            style: TextStyle(fontSize: 18),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: isTextArea ? null : 1,
            minLines: isTextArea ? minLines : 1,
            obscureText: isPassword,
            keyboardType: numbersOnly
                ? TextInputType.number
                : (isPassword
                    ? TextInputType.visiblePassword
                    : TextInputType.text),
            inputFormatters: numbersOnly
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    if (maxLength != null)
                      LengthLimitingTextInputFormatter(maxLength!),
                  ]
                : (maxLength != null
                    ? [LengthLimitingTextInputFormatter(maxLength!)]
                    : null),
            decoration: InputDecoration(
              hintTextDirection: TextDirection.rtl,
              border: OutlineInputBorder(
                gapPadding: 1.0,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: fieldHeight + 5, horizontal: 15),
              hintText: textHint,
              hintStyle: TextStyle(
                textBaseline: TextBaseline.alphabetic,
                color: Colors.grey[500],
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.borderGrey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.darkergrey, width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validationMessage;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
