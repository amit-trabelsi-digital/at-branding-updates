import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/screens/general/case_and_react.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_accordion.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_case_and_reaction_card.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/top_image_layout.dart';
import 'package:provider/provider.dart';

class CaseAndReactions extends StatefulWidget {
  const CaseAndReactions({super.key});

  @override
  State<CaseAndReactions> createState() => _CaseAndReactionsState();
}

class _CaseAndReactionsState extends State<CaseAndReactions> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final DataProvider dataProvider = Provider.of<DataProvider>(context);
    return TopImageLayout(
        title: 'מקרים ותגובות',
        imageSrc: 'images/school.png',
        darkLinear: true,
        cardChildren: [
          Accordion(
              title:
                  'הרגלים של אלופים ( ${dataProvider.caseAndResponse.length} )',
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              useCard: false,
              softTitleStyle: true,
              child: Column(
                spacing: 10,
                children: [
                  ...dataProvider.caseAndResponse
                      .map((item) => AppCaseAndReactionsCard(
                            title: item.caseName,
                            text: 'אין תוכן זמין',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CaseAndReactPage(
                                        caseAndResponseData: item,
                                        title: item.caseName,
                                        imageSrc: 'images/school.png',
                                      )),
                            ),
                          )),
                  // AppCaseAndReactionsCard(
                  //   title: 'טקס שינה של אלופים',
                  //   text:
                  //       'איך נערכים בלילה שלפני ומארגנים את המחשבות והאנרגיות כדי ליצור אימפקט ופוקוס מקסימלי ביום המשחק',
                  //   videoTime: '03:24',
                  //   // use navigator for navigation
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const CaseAndReactPage(
                  //               title: 'בדיקרה',
                  //               imageSrc: 'images/school.png',
                  //             )),
                  //   ),
                  // ),
                  // AppCaseAndReactionsCard(
                  //     title: 'טקס שינה של אלופים',
                  //     text:
                  //         'איך נערכים בלילה שלפני ומארגנים את המחשבות והאנרגיות כדי ליצור אימפקט ופוקוס מקסימלי ביום המשחק',
                  //     videoTime: '03:24'),
                  // AppCaseAndReactionsCard(
                  //     title: 'טקס שינה של אלופים',
                  //     text:
                  //         'איך נערכים בלילה שלפני ומארגנים את המחשבות והאנרגיות כדי ליצור אימפקט ופוקוס מקסימלי ביום המשחק',
                  //     videoTime: '03:24'),
                ],
              )),
        ],
        formKey: _formKey);
  }
}
