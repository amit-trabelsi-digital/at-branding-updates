// filepath: /C:/Users/mtndb/OneDrive/Desktop/development/AmitTLD/mental-coach-flutter/lib/providers/data_provider.dart
import 'package:color_simp/color_simp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/config/environment_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/models/general_models.dart';

class DataProvider with ChangeNotifier {
  List<League> _leagues = [];
  List<Team> _teams = [];
  List<PersonalityGroup> _personalityGroups = [];
  List<CaseAndResponseModel> _caseAndResponse = [];
  String _appVersion = '';
  final String credits = 'פיתוח: עמית טרבלסי';
  Map<String, dynamic> _generalData = {};
  // Color _selectedColor = const Color(0xFFFF42C1);
  Color _selectedColor = const Color(0xff292929);

  List<League> get leagues => _leagues;
  List<Team> get teams => _teams;
  List<PersonalityGroup> get personalityGroups => _personalityGroups;
  List<CaseAndResponseModel> get caseAndResponse => _caseAndResponse;
  Map<String, dynamic> get generalData => _generalData;
  Color get selectedColor => _selectedColor;
  String get appVersion => _appVersion;

  DataProvider() {
    fetchDropdownData();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    // This will not work on web, so we'll just use a default value
    if (kIsWeb) {
      _appVersion = '1.0.0-web';
      notifyListeners();
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      notifyListeners();
    } catch (e) {
      print('Error loading app version: $e');
      _appVersion = '0.0.0'; // ערך ברירת מחדל במקרה של שגיאה
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      "Fetching dropdown data".blue.log();
      final leaguesResponse = await http
          .get(Uri.parse('${EnvironmentConfig.instance.serverURL}/leagues'));
      final teamsResponse = await http
          .get(Uri.parse('${EnvironmentConfig.instance.serverURL}/teams'));
      final personalityResponse = await http.get(Uri.parse(
          '${EnvironmentConfig.instance.serverURL}/personallity-groups'));
      final caseAndResponseResponse = await http
          .get(Uri.parse('${EnvironmentConfig.instance.serverURL}/cases'));
      final generalDataResponse = await http.get(
          Uri.parse('${EnvironmentConfig.instance.serverURL}/general/data'));

      if (leaguesResponse.statusCode == 200 &&
          teamsResponse.statusCode == 200 &&
          personalityResponse.statusCode == 200 &&
          caseAndResponseResponse.statusCode == 200 &&
          generalDataResponse.statusCode == 200) {
        // Parse JSON in the main isolate instead of using compute
        final leaguesJson = json.decode(leaguesResponse.body) as List;
        final teamJson = json.decode(teamsResponse.body) as List;
        final personalityJson = json.decode(personalityResponse.body) as List;
        final caseAndResponseJson =
            json.decode(caseAndResponseResponse.body) as List;
        final generalDataJson = json.decode(generalDataResponse.body);

        // Parse directly without compute first to identify the issue
        _leagues = parseLeagues(leaguesJson);
        _teams = parseTeams(teamJson);
        _personalityGroups = parsePersonalityGroups(personalityJson);
        _caseAndResponse = parseCaseAndResponse(caseAndResponseJson);
        _generalData = parseGeneralData(generalDataJson);

        notifyListeners();
      } else {
        "Failed to load dropdown data".red.log();
        throw Exception('Failed to load dropdown data');
      }
    } catch (e) {
      "Error loading data in data_provider $e".red.log();
      print(e);
      throw Exception('Error loading data: $e');
    }
  }

  List<League> parseLeagues(List<dynamic> leaguesJson) {
    return leaguesJson.map((json) => League.fromJson(json)).toList();
  }

  List<Team> parseTeams(List<dynamic> teamJson) {
    return teamJson.map((json) => Team.fromJson(json)).toList();
  }

  List<PersonalityGroup> parsePersonalityGroups(List<dynamic> personalityJson) {
    return personalityJson
        .map((json) => PersonalityGroup.fromJson(json))
        .toList();
  }

  List<CaseAndResponseModel> parseCaseAndResponse(
      List<dynamic> caseAndResponseJson) {
    return caseAndResponseJson
        .map((json) => CaseAndResponseModel.fromJson(json))
        .toList();
  }

  Map<String, dynamic> parseGeneralData(dynamic generalDataJson) {
    return generalDataJson is Map<String, dynamic> ? generalDataJson : {};
  }

  void updateSelectedColor(Color newColor) {
    _selectedColor = newColor;
    notifyListeners();
  }
}
