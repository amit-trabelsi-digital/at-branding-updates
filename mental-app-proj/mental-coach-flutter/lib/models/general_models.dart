class Position {
  final String value;
  final String label;

  Position({
    required this.value,
    required this.label,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      value: json['value'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class Goal {
  final String id;
  final String goalName;
  final List<Position> positions;
  final bool measurable;

  Goal({
    required this.id,
    required this.goalName,
    required this.positions,
    required this.measurable,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['_id'],
      goalName: json['goalName'],
      positions: (json['positions'] as List)
          .map((position) => Position.fromJson(position))
          .toList(),
      measurable: json['measurable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'goalName': goalName,
      'positions': positions.map((position) => position.toJson()).toList(),
      'measurable': measurable,
    };
  }
}

class PersonalityTag {
  final String label;
  final String value;

  PersonalityTag({
    required this.label,
    required this.value,
  });

  factory PersonalityTag.fromJson(Map<String, dynamic> json) {
    return PersonalityTag(
      label: json['label'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class PersonalityGroup {
  final String title;
  final List<PersonalityTag> tags;

  PersonalityGroup({
    required this.title,
    required this.tags,
  });

  factory PersonalityGroup.fromJson(Map<String, dynamic> json) {
    return PersonalityGroup(
      title: json['title'],
      tags: (json['tags'] as List)
          .map((tag) => PersonalityTag.fromJson(tag))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}
