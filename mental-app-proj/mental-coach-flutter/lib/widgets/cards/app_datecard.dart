import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';

class DateCard extends StatelessWidget {
  final String date;
  final String day;
  final String month;

  const DateCard(
      {super.key, this.date = '1', this.day = 'ראשון', this.month = 'ינואר'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 118,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.borderGrey),
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 54,
                child: Text(day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              AppTitle(
                title: date,
                fontSize: 60,
                lineHeight: 1,
                verticalMargin: 0,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(
                width: 54,
                child: Text(month,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1,
                      fontWeight: FontWeight.w400,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
