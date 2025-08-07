import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';

List<Color> footballTeamColors = [
  Colors.red,
  Colors.blue,
  Colors.white,
  Colors.black,
  Colors.yellow,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Color(0xFF800000),
  Color(0xFFFFD700),
  Color(0xFFC0C0C0),
  Colors.teal,
  Colors.pink,
];

class AppColors {
  static const Color grey = Color(0xFFE2E2E2);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color darkgrey = Color(0xFFD0D0D0);
  static const Color darkergrey = Color(0xFF686868);
  static const Color borderGrey = Color(0xFFCFCFCF);
  static const Color shadowGrey = Color.fromARGB(82, 180, 180, 180);
  static const Color pink = Color(0xFFFF42C1);
  static const Color oldPink = Color(0xFFFFD2D2);
  static const Color appBG = Color(0xFFFAFAFA);
  static const Color primary = Color(0xFF22242F);
  static const Color secondary = Color(0xFF4A90E2); // הוספת צבע משני
  static const Color primaryDark = Color(0xFF0C0C0C);
  static const Color lightPurple = Color(0xFFF9E7FF);
  static const Color black = Color(0xFF2A2A2A);

  static Color getSelectedColor(BuildContext context) {
    return Provider.of<DataProvider>(context, listen: true).selectedColor;
  }
}

class Position {
  final String value;
  final String label;

  Position({required this.value, required this.label});
}

final List<Position> positions = [
  Position(value: "GK", label: "שוער"), // Goalkeeper
  Position(value: "CB", label: "בלם"), // Center Back
  Position(value: "LB", label: "מגן שמאלי"), // Left Back
  Position(value: "RB", label: "מגן ימני"), // Right Back
  Position(value: "LWB", label: "מגן שמאלי תוקף"), // Left Wing Back
  Position(value: "RWB", label: "מגן ימני תוקף"), // Right Wing Back
  Position(value: "CDM", label: "קשר אחורי"), // Central Defensive Midfielder
  Position(value: "CM", label: "קשר מרכזי"), // Central Midfielder
  Position(value: "CAM", label: "קשר התקפי"), // Central Attacking Midfielder
  Position(value: "LM", label: "קשר שמאלי"), // Left Midfielder
  Position(value: "RM", label: "קשר ימני"), // Right Midfielder
  Position(value: "LW", label: "קיצוני שמאלי"), // Left Winger
  Position(value: "RW", label: "קיצוני ימני"), // Right Winger
  Position(value: "CF", label: "חלוץ מרכזי"), // Center Forward
  Position(value: "ST", label: "חלוץ"), // Striker
];

class AppShadows {
  static const BoxShadow defaultShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0,
        0.12), // Updated shadow color with lighter opacity (matches Figma)
    spreadRadius: 0, // Reduced spread for cleaner look
    blurRadius: 5, // Consistent with Figma design
    offset: Offset(0, 0), // Centered shadow
  );
  static const BoxShadow softShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08), // Even softer shadow
    spreadRadius: 0,
    blurRadius: 8,
    offset: Offset(0, 4), // Slight vertical offset for depth
  );
}

final List<String> FEEEL_LIST_1 = [
  'ממש \n לא',
  'אולי \n קצת',
  'לפעמים \n כן',
  'באופן \n קבוע',
  'ממש \n קיצוני'
];

final List<String> FEEEL_LIST_2 = [
  'בכלל \n לא',
  'אולי \n קצת',
  'במידה \n סבירה',
  'בהחלט \n כן',
  'מעל \n ומעבר'
];

List<Map<String, String>> oldList = [
  {"title": "Old Item 1", "subtitle": "Subtitle 1"},
  {"title": "Old Item 2", "subtitle": "Subtitle 2"},
  {"title": "Old Item 3", "subtitle": "Subtitle 3"},
];

List<Map<String, String>> newList = [
  {"title": "New Item 1", "subtitle": "Subtitle 1"},
  {"title": "New Item 2", "subtitle": "Subtitle 2"},
  {"title": "New Item 3", "subtitle": "Subtitle 3"},
];

List<String> WEEK_DAYS = [
  'ראשון',
  'שני',
  'שלישי',
  'רביעי',
  'חמישי',
  'שישי',
  'שבת'
];

List<String> MONTHS = [
  'ינואר',
  'פברואר',
  'מרץ',
  'אפריל',
  'מאי',
  'יוני',
  'יולי',
  'אוגוסט',
  'ספטמבר',
  'אוקטובר',
  'נובמבר',
  'דצמבר'
];
