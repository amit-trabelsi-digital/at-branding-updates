import 'dart:ui';

import 'package:color_simp/color_simp.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_mission_card.dart';

String? getIdByKeyValue<T>(List<dynamic> items, String value) {
  try {
    for (var item in items) {
      // Handle both map-like access and property access
      if ((item is Map && item['name'] == value) ||
          (item is! Map && item.name == value)) {
        // Return the id, handling both map-like and property access
        return item is Map ? item['_id'] : item.id;
      }
    }
    return null; // Return null if no match is found
  } catch (e) {
    "GET ID BY KEY VALUE ERROR: $e".red.log();
  }
  return null;
}

String getLabelByValue(List<dynamic> items, String value) {
  for (var item in items) {
    if (item.value == value) {
      // Access property directly
      return item.label;
    }
  }
  return '--'; // Return null if no match is found
}

String? getValueByLabel(List<dynamic> items, String label) {
  for (var item in items) {
    if (item.label == label) {
      // Access property directly
      return item.value;
    }
  }
  return null; // Return null if no match is found
}

Color hexToFlutterColor(String hex) {
  final String cleanedHex = hex.replaceFirst('#', '');
  return Color(int.parse('0xFF$cleanedHex'));
}

String flutterColorToHex(Color color) {
  return '#${color.toHexString().substring(2)}';
}

String? getKeyByKey(
  List<dynamic> items,
  String value,
  List<String> keys, // List of keys to choose from dynamically
) {
  for (var item in items) {
    for (var key in keys) {
      if (item[key] == value) {
        // You can customize this based on how you want to return the label
        return item[
            keys.first]; // Example: returning the first key's value as label
      }
    }
  }
  return null; // Return null if no match is found
}

String formatDateToHebrew(DateTime? date, {bool short = false}) {
  // Define the day names and month names in Hebrew

  if (date == null) return '--';

  // Get the day of the week and month in Hebrew
  String dayName = WEEK_DAYS[date.weekday % 7];
  String monthName = MONTHS[date.month - 1];

  // Format the date string
  if (short) {
    return '${date.day} $monthName';
  }
  String formattedDate = '$dayName, ${date.day} $monthName';

  return formattedDate;
}

Match? findSoonestMatch(List<Match>? matches) {
  if (matches!.isEmpty) {
    'Matches is empty'.cyan.log();
    return null;
  }

  Match soonestMatch = matches[0];
  for (var match in matches) {
    if (match.date.isBefore(soonestMatch.date)) {
      soonestMatch = match;
    }
  }
  return soonestMatch;
}

dynamic findSoonestEvent(List<Match>? matches, List<Training>? trainings) {
  List<dynamic> allEvents = [];

  // Combine all events into a single list
  if (matches != null && matches.isNotEmpty) {
    allEvents.addAll(matches);
  }

  if (trainings != null && trainings.isNotEmpty) {
    allEvents.addAll(trainings);
  }

  if (allEvents.isEmpty) {
    'No events to check'.cyan.log();
    return null;
  }

  dynamic soonestEvent = allEvents[0];
  DateTime soonestDate = allEvents[0].date;

  for (var event in allEvents) {
    if (event.date.isBefore(soonestDate)) {
      soonestEvent = event;
      soonestDate = event.date;
    }
  }

  return soonestEvent;
}
// ...existing code...

dynamic findOpenMatchOrTraining(
    List<Match>? matches, List<Training>? trainings) {
  // First check matches
  if (matches != null && matches.isNotEmpty) {
    for (var match in matches) {
      if (match.isOpen == true) {
        return match;
      }
    }
  }

  // Then check trainings
  if (trainings != null && trainings.isNotEmpty) {
    for (var training in trainings) {
      if (training.isOpen == true) {
        return training;
      }
    }
  }

  final soonestEvent = findSoonestEvent(matches, trainings);
  if (soonestEvent != null) {
    return soonestEvent;
  }
  'No open match or training found'.cyan.log();
  return null;
}

String daysUntil(DateTime? date) {
  if (date == null) return '--';

  final now = DateTime.now();

  // Strip time portions to compare calendar days only
  final dateOnly = DateTime(date.year, date.month, date.day);
  final nowOnly = DateTime(now.year, now.month, now.day);

  final difference = dateOnly.difference(nowOnly).inDays;

  if (difference == 1) {
    return 'מחר';
  } else if (difference == 0) {
    return 'היום';
  } else if (difference > 0) {
    return 'עוד $difference ימים';
  } else {
    // Handle past dates with "לפני X ימים"
    final daysAgo = difference.abs();
    if (daysAgo == 1) {
      return 'אתמול';
    }
    return 'לפני $daysAgo ימים';
  }
}

String getIconPath(IconType iconType) {
  switch (iconType) {
    case IconType.person:
      return icons['person']!;
    case IconType.learn:
      return icons['learn']!;
    case IconType.brain:
      return icons['brain']!;
  }
}

/// בודק אם למשחק או פעילות יש מטרה ריקה או פעולות ריקות
/// מחזיר true אם המטרה ריקה וגם אין פעולות תקינות
bool hasEmptyGoalAndAction(ActivityBase? match) {
  if (match == null) return false;

  // בדיקה אם המטרה ריקה
  bool hasEmptyGoal = match.goal == null ||
      match.goal!.goalName == null ||
      match.goal!.goalName == '';

  // בדיקה אם יש פעולות תקינות (עם שם)
  bool hasValidActions = false;
  if (match.actions != null && match.actions!.isNotEmpty) {
    for (var action in match.actions!) {
      if (action.actionName.isNotEmpty) {
        hasValidActions = true;
        break;
      }
    }
  }

  // מחזיר true אם המטרה ריקה וגם אין פעולות תקינות
  final result = hasEmptyGoal && !hasValidActions;
  'hasEmptyGoal: $hasEmptyGoal, hasValidActions: $hasValidActions, result: $result'
      .red
      .log();
  return result;
}

double calculateMatchPerformance(ActivityBase match) {
  List<JoinAction>? actions = match.actions;
  double personalityPerformed =
      match.personalityGroup?.performed?.toDouble() ?? 0.0;

  double goalValue = match.goal?.performed ?? 0.0;

  // Calculate average of actions.performed
  double actionsTotal = 0.0;
  if (actions != null && actions.isNotEmpty) {
    actionsTotal =
        actions.fold(0.0, (sum, action) => sum + (action.performed.toDouble()));
    actionsTotal = actionsTotal / actions.length;
  }

  // Ensure all values are between 0 and 1
  goalValue = goalValue.clamp(0.0, 1.0);
  actionsTotal = actionsTotal.clamp(0.0, 1.0);
  personalityPerformed = personalityPerformed.clamp(0.0, 1.0);

  // Calculate final percentage (average of all three components)
  double totalPerformance =
      (goalValue + actionsTotal + personalityPerformed) / 3;
  double percentage = totalPerformance * 100;

  "$percentage from calculate function".green.log();
  return double.parse(percentage
      .toStringAsFixed(2)); // Returns percentage with 2 decimal places
}

String extractVimeoId(String? url) {
  if (url == null || url.isEmpty) {
    print('extractVimeoId: URL is null or empty');
    return '';
  }

  print('extractVimeoId: Processing URL: $url');

  // בדיקה אם ה-URL הוא כבר רק ה-ID
  if (RegExp(r'^\d+$').hasMatch(url)) {
    print('extractVimeoId: URL is already an ID: $url');
    return url;
  }

  // Try to match various Vimeo URL formats
  RegExp regExp = RegExp(
    r'(?:vimeo\.com\/|player\.vimeo\.com\/video\/)(\d+)',
    caseSensitive: false,
  );

  RegExpMatch? match = regExp.firstMatch(url);
  if (match != null) {
    String id = match[1] ?? '';
    print('extractVimeoId: Found ID: $id');
    return id;
  }

  print('extractVimeoId: No ID found in URL');
  return '';
}

bool isWithin24Hours(DateTime? date) {
  if (date == null) return false;

  final now = DateTime.now();

  final difference = now.difference(date).abs();

  return difference.inHours < 24 || difference.inHours > 0;
}

String formatTimeHHMM(DateTime? dateTime) {
  if (dateTime == null) return '--';

  int hours = dateTime.hour;
  int minutes = dateTime.minute;

  String formattedHours = hours.toString().padLeft(2, '0');
  String formattedMinutes = minutes.toString().padLeft(2, '0');

  return '$formattedHours:$formattedMinutes';
}

String timeUntilMatch(DateTime? date) {
  if (date == null) return '--';

  final now = DateTime.now();
  final difference = date.difference(now);

  if (difference.isNegative) {
    // המשחק כבר עבר
    return 'המשחק עבר';
  }

  final hours = difference.inHours;
  final minutes = difference.inMinutes % 60;

  if (hours == 0) {
    if (minutes == 0) {
      return 'עכשיו';
    }
    return 'עוד $minutes דקות';
  } else if (hours == 1) {
    if (minutes == 0) {
      return 'עוד שעה';
    }
    return 'עוד שעה ו-$minutes דקות';
  } else {
    if (minutes == 0) {
      return 'עוד $hours שעות';
    }
    return 'עוד $hours שעות ו-$minutes דקות';
  }
}
