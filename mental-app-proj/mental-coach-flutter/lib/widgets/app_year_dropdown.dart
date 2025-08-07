import 'package:flutter/material.dart';

class AppYearDropdown extends StatelessWidget {
  final String selectedYear;
  final ValueChanged<String?> onYearChanged;

  const AppYearDropdown(
      {super.key, required this.selectedYear, required this.onYearChanged});

  @override
  Widget build(BuildContext context) {
    // יצירת רשימת שנים דינמית שכוללת את השנה הנוכחית
    final currentYear = DateTime.now().year;
    List<String> years = [];

    // הוספת השנים האחרונות (כולל השנה הנוכחית)
    for (int i = 0; i < 5; i++) {
      final startYear = currentYear - i;
      final endYear = startYear + 1;
      years.add('$startYear-$endYear');
    }

    // וידוא שהערך הנבחר קיים ברשימה
    if (!years.contains(selectedYear)) {
      years.insert(0, selectedYear);
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: Colors.white,
        value: selectedYear,
        onChanged: onYearChanged,
        items: years.map((String year) {
          return DropdownMenuItem<String>(
            value: year,
            child: Text(
              year,
              style: TextStyle(fontSize: 18),
              textDirection: TextDirection.ltr,
            ),
          );
        }).toList(),
      ),
    );
  }
}
