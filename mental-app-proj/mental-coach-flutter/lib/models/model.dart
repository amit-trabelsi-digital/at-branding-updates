class League {
  final String id;
  final String name;

  League({required this.id, required this.name});

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class UserLeague {
  final String name;

  UserLeague({required this.name});

  factory UserLeague.fromJson(Map<String, dynamic> json) {
    return UserLeague(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class UserTeam {
  final String name;

  UserTeam({required this.name});

  factory UserTeam.fromJson(Map<String, dynamic> json) {
    return UserTeam(
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class Team {
  final String? id;
  final String? name;
  final String? hex1;
  final String? hex2;
  final String? hex3;

  Team({required this.id, required this.name, this.hex1, this.hex2, this.hex3});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'],
      name: json['name'],
      hex1: json['hex1'],
      hex2: json['hex2'],
      hex3: json['hex3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'hex1': hex1, 'hex2': hex2, 'hex3': hex3};
  }
}

class Score {
  final int home;
  final int away;

  Score({required this.home, required this.away});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      home: json['home'],
      away: json['away'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home,
      'away': away,
    };
  }
}

// Add this base class above the Match and Training classes

abstract class ActivityBase {
  final String id;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JoinPersonalityGroup? personalityGroup;
  final List<JoinAction>? actions;
  final JoinGoal? goal;
  final String? season;
  final bool? investigation;
  final bool isOpen;
  final String? note;

  ActivityBase({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.personalityGroup,
    this.actions,
    this.goal,
    this.season,
    this.investigation = false,
    required this.isOpen,
    this.note,
  });

  Map<String, dynamic> toJsonBase() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'actions': actions?.map((item) => item.toJson()).toList(),
      'goal': goal?.toJson(),
      'personalityGroup': personalityGroup?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'season': season,
      'investigation': investigation,
      'isOpen': isOpen,
      'note': note,
    };
  }
}

// Then modify your Match class to extend ActivityBase
class Match extends ActivityBase {
  final Team homeTeam;
  final Team awayTeam;
  final Score score;
  final String? matchResult;
  final bool? isHomeMatch;
  final bool isUserPickedTime; // New field

  Match({
    required super.id,
    required super.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    required super.createdAt,
    required super.updatedAt,
    required super.isOpen,
    super.personalityGroup,
    super.actions,
    super.goal,
    super.season,
    super.investigation,
    this.matchResult,
    this.isHomeMatch,
    required this.isUserPickedTime,
    super.note,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      homeTeam: Team.fromJson(json['homeTeam']),
      awayTeam: Team.fromJson(json['awayTeam']),
      score: Score.fromJson(json['score']),
      goal: json['goal'] != null ? JoinGoal.fromJson(json['goal']) : null,
      actions: json['actions'] != null
          ? (json['actions'] as List)
              .map((item) => JoinAction.fromJson(item))
              .toList()
          : [],
      personalityGroup: json['personalityGroup'] != null
          ? JoinPersonalityGroup.fromJson(json['personalityGroup'])
          : null,
      season: json['season'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      investigation: json['investigation'],
      isOpen: json['isOpen'],
      matchResult: json['matchResult'],
      isHomeMatch: json['isHomeMatch'],
      isUserPickedTime: json['isUserPickedTime'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    final baseJson = super.toJsonBase();
    return {
      ...baseJson,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'score': score.toJson(),
      'matchResult': matchResult,
      'isHomeMatch': isHomeMatch,
      'isUserPickedTime': isUserPickedTime,
    };
  }
}

// And modify your Training class to extend ActivityBase
class Training extends ActivityBase {
  final bool? isUserPickedTime; // New field

  Training({
    required super.id,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    required super.isOpen,
    super.personalityGroup,
    super.actions,
    super.goal,
    super.season,
    super.investigation,
    super.note,
    this.isUserPickedTime,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['_id'],
      date: DateTime.parse(json['date']),
      goal: json['goal'] != null ? JoinGoal.fromJson(json['goal']) : null,
      actions: json['actions'] != null
          ? (json['actions'] as List)
              .map((item) => JoinAction.fromJson(item))
              .toList()
          : [],
      personalityGroup: json['personalityGroup'] != null
          ? JoinPersonalityGroup.fromJson(json['personalityGroup'])
          : null,
      season: json['season'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      investigation: json['investigation'],
      isOpen: json['isOpen'],
      note: json['note'],
      isUserPickedTime: json['isUserPickedTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final baseJson = super.toJsonBase();
    return {
      ...baseJson,
      'isUserPickedTime': isUserPickedTime,
    };
  }
}

// JoinAction and Goals for JoinMatch
class JoinAction {
  final String actionName;
  double performed; // Removed 'final' keyword to make it mutable

  JoinAction({
    required this.actionName,
    this.performed = 0,
  });

  factory JoinAction.fromJson(Map<String, dynamic> json) {
    var performedValue = json['performed'];
    double performedDouble;

    if (performedValue == null) {
      performedDouble = 0.0;
    } else if (performedValue is int) {
      performedDouble = performedValue.toDouble();
    } else {
      performedDouble = performedValue;
    }

    return JoinAction(
      actionName: json['actionName'],
      performed: performedDouble,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionName': actionName,
      'performed': performed,
    };
  }
}

class JoinGoal {
  final String? goalName;
  double performed; // Removed 'final' keyword to make it mutable

  JoinGoal({
    this.goalName,
    this.performed = 0,
  });

  factory JoinGoal.fromJson(Map<String, dynamic> json) {
    var performedValue = json['performed'];
    double performedDouble;

    if (performedValue == null) {
      performedDouble = 0.0;
    } else if (performedValue is int) {
      performedDouble = performedValue.toDouble();
    } else {
      performedDouble = performedValue;
    }

    return JoinGoal(
      goalName: json['goalName'],
      performed: performedDouble,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalName': goalName,
      'performed': performed,
    };
  }
}

class JoinPersonalityGroup {
  final String? title;
  final String? tag;
  final double? performed;

  JoinPersonalityGroup({
    this.title,
    this.tag,
    this.performed,
  });

  factory JoinPersonalityGroup.fromJson(Map<String, dynamic> json) {
    var performedValue = json['performed'];
    double performedDouble;

    if (performedValue == null) {
      performedDouble = 0.0;
    } else if (performedValue is int) {
      performedDouble = performedValue.toDouble();
    } else {
      performedDouble = performedValue;
    }
    return JoinPersonalityGroup(
      title: json['title'],
      tag: json['tag'],
      performed: performedDouble,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'tag': tag ?? '', 'performed': performed};
  }
}

class TrainingProgram {
  final String id;
  final String name;

  TrainingProgram({required this.id, required this.name});

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    return TrainingProgram(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class CurrentStatus {
  final String title;
  final int rating;

  CurrentStatus({required this.title, required this.rating});

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
      title: json['title'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rating': rating,
    };
  }
}

class SelectedTeamColor {
  final String? hex1;
  final String? hex2;
  final String? hex3;

  SelectedTeamColor({this.hex1, this.hex2, this.hex3});

  factory SelectedTeamColor.fromJson(Map<String, dynamic> json) {
    return SelectedTeamColor(
      hex1: json['hex1'],
      hex2: json['hex2'],
      hex3: json['hex3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hex1': hex1,
      'hex2': hex2,
      'hex3': hex3,
    };
  }
}

class EncouragementSystemMessage {
  final String title;
  final String description;
  final String? image;
  final DateTime date;
  final bool confirmed;

  EncouragementSystemMessage({
    required this.title,
    required this.description,
    this.image,
    required this.date,
    required this.confirmed,
  });

  factory EncouragementSystemMessage.fromJson(Map<String, dynamic> json) {
    return EncouragementSystemMessage(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      date: DateTime.parse(json['date']),
      confirmed: json['confirmed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'date': date.toIso8601String(),
      'confirmed': confirmed,
    };
  }
}

class AppUser {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? password;
  final String? uid;
  final String? playerNumber;
  final String? nickName;
  final int? age;
  final String? position;
  final String? bio;
  final String? strongLeg;
  final List<CurrentStatus>? currentStatus;
  final League? league;
  final UserLeague? userLeague;
  final UserTeam? userTeam;
  final Team? team;
  final SelectedTeamColor? selectedTeamColor;
  final List<Match>? matches;
  final List<Training>? trainings;
  final String? subscriptionType;
  final int? totalScore;
  final int? seasons;
  final List<EncouragementSystemMessage>? encouragementSystemMessages;
  final int? certificationsNumber;
  final int? totalWins;
  final TrainingProgram? trainingProgram;
  final DateTime? createdAt;
  final bool? setProfileComplete;
  final bool? setGoalAndProfileComplete;
  final String? theDream;
  final String? breakOutSeason;

  AppUser(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.password,
      this.uid,
      this.nickName,
      this.age,
      this.position,
      this.bio,
      this.strongLeg,
      this.currentStatus,
      this.league,
      this.team,
      this.userLeague,
      this.userTeam,
      this.selectedTeamColor,
      this.matches,
      this.trainings,
      this.subscriptionType,
      this.totalScore,
      this.seasons,
      this.encouragementSystemMessages,
      this.certificationsNumber,
      this.totalWins,
      this.trainingProgram,
      this.playerNumber,
      this.createdAt,
      this.setGoalAndProfileComplete,
      this.setProfileComplete,
      this.breakOutSeason,
      this.theDream});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        phone: json['phone'],
        password: json['password'],
        uid: json['uid'],
        nickName: json['nickName'],
        age: json['age'],
        position: json['position'],
        bio: json['bio'],
        strongLeg: json['strongLeg'],
        currentStatus: json['currentStatus'] != null
            ? (json['currentStatus'] as List)
                .map((item) => CurrentStatus.fromJson(item))
                .toList()
            : null,
        league: json['league'] != null ? League.fromJson(json['league']) : null,
        team: json['team'] != null ? Team.fromJson(json['team']) : null,
        userLeague: json['userLeague'] != null
            ? UserLeague.fromJson(json['userLeague'])
            : null,
        userTeam: json['userTeam'] != null
            ? UserTeam.fromJson(json['userTeam'])
            : null,
        selectedTeamColor: json['selectedTeamColor'] != null
            ? SelectedTeamColor.fromJson(json['selectedTeamColor'])
            : null,
        matches: json['matches'] != null
            ? (json['matches'] as List)
                .map((item) => Match.fromJson(item))
                .toList()
            : null,
        trainings: json['trainings'] != null
            ? (json['trainings'] as List)
                .map((item) => Training.fromJson(item))
                .toList()
            : null,
        subscriptionType: json['subscriptionType'],
        totalScore: json['totalScore'] ?? 0,
        seasons: json['seasons'],
        encouragementSystemMessages: json['encouragementSystemMessages'] != null
            ? (json['encouragementSystemMessages'] as List)
                .map((item) => EncouragementSystemMessage.fromJson(item))
                .toList()
            : null,
        certificationsNumber: json['certificationsNumber'],
        totalWins: json['totalWins'] ?? 0,
        trainingProgram: json['trainingProgram'] != null
            ? TrainingProgram.fromJson(json['trainingProgram'])
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        setGoalAndProfileComplete: json['setGoalAndProfileComplete'],
        setProfileComplete: json['setProfileComplete'],
        theDream: json['theDream'],
        playerNumber: json['playerNumber'],
        breakOutSeason: json['breakOutSeason']);
  }

  get blue => null;

  Match? get soonestMatch => null;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'password': password,
      'uid': uid,
      'nickName': nickName,
      'age': age,
      'position': position,
      'bio': bio,
      'playerNumber': playerNumber,
      'strongLeg': strongLeg,
      'currentStatus': currentStatus?.map((item) => item.toJson()).toList(),
      'league': league?.toJson(),
      'team': team?.toJson(),
      'userLeague': userLeague?.toJson(),
      'userTeam': userTeam?.toJson(),
      'selectedTeamColor': selectedTeamColor?.toJson(),
      'matches': matches?.map((item) => item.toJson()).toList(),
      'trainings': trainings?.map((item) => item.toJson()).toList(),
      'subscriptionType': subscriptionType,
      'totalScore': totalScore,
      'seasons': seasons,
      'encouragementSystemMessages':
          encouragementSystemMessages?.map((item) => item.toJson()).toList(),
      'certificationsNumber': certificationsNumber,
      'totalWins': totalWins,
      'trainingProgram': trainingProgram?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'setGoalAndProfileComplete': setGoalAndProfileComplete,
      'setProfileComplete': setProfileComplete,
      'theDream': theDream,
      'breakOutSeason': breakOutSeason,
    };
  }

  // Add this method to your AppUser class
  AppUser copyWith(Map<String, dynamic> updates) {
    return AppUser(
      id: updates['id'] ?? id,
      firstName: updates['firstName'] ?? firstName,
      lastName: updates['lastName'] ?? lastName,
      email: updates['email'] ?? email,
      phone: updates['phone'] ?? phone,
      password: updates['password'] ?? password,
      uid: updates['uid'] ?? uid,
      nickName: updates['nickName'] ?? nickName,
      age: updates['age'] ?? age,
      position: updates['position'] ?? position,
      bio: updates['bio'] ?? bio,
      strongLeg: updates['strongLeg'] ?? strongLeg,
      currentStatus: updates['currentStatus'] ?? currentStatus,
      league: updates['league'] ?? league,
      team: updates['team'] ?? team,
      matches: updates['matches'] ?? matches,
      trainings: updates['trainings'] ?? trainings,
      subscriptionType: updates['subscriptionType'] ?? subscriptionType,
      totalScore: updates['totalScore'] ?? totalScore,
      seasons: updates['seasons'] ?? seasons,
      encouragementSystemMessages:
          updates['encouragementSystemMessages'] ?? encouragementSystemMessages,
      certificationsNumber:
          updates['certificationsNumber'] ?? certificationsNumber,
      totalWins: updates['totalWins'] ?? totalWins,
      trainingProgram: updates['trainingProgram'] ?? trainingProgram,
      createdAt: updates['createdAt'] ?? createdAt,
      setProfileComplete: updates['setProfileComplete'] ?? setProfileComplete,
      setGoalAndProfileComplete:
          updates['setGoalAndProfileComplete'] ?? setGoalAndProfileComplete,
      breakOutSeason: updates['breakOutSeason'] ?? breakOutSeason,
      theDream: updates['theDream'] ?? theDream,
      selectedTeamColor: updates['selectedTeamColor'] ?? selectedTeamColor,
      playerNumber: updates['playerNumber'] ?? playerNumber,
      userLeague: updates['userLeague'] ?? userLeague,
      userTeam: updates['userTeam'] ?? userTeam,
    );
  }
}

class CaseAndResponseModel {
  final String caseName;
  final String response;
  final String responseState;
  final String link;
  final bool sent;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String notes;
  final List<Position> positions;
  final List<Tag> tags;

  CaseAndResponseModel({
    required this.caseName,
    required this.response,
    required this.responseState,
    required this.link,
    required this.sent,
    required this.createdAt,
    this.sentAt,
    required this.notes,
    required this.positions,
    required this.tags,
  });

  factory CaseAndResponseModel.fromJson(Map<String, dynamic> json) {
    return CaseAndResponseModel(
      caseName: json['case'] as String,
      response: json['response'] as String,
      responseState: json['responseState'] as String,
      link: json['link'] as String,
      sent: json['sent'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      notes: json['notes'] as String,
      positions: (json['positions'] as List)
          .map((item) => Position.fromJson(item as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List)
          .map((item) => Tag.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case': caseName,
      'response': response,
      'responseState': responseState,
      'link': link,
      'sent': sent,
      'createdAt': createdAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'notes': notes,
      'positions': positions.map((p) => p.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
    };
  }
}

class Position {
  final String value;
  final String label;

  Position({
    required this.value,
    required this.label,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}

class Tag {
  final String value;
  final String label;

  Tag({
    required this.value,
    required this.label,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
