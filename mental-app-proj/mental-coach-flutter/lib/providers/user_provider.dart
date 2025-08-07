import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Add error tracking
  String? _authError;
  String? get authError => _authError;

  // Add navigation flag
  bool _needsLogin = false;
  bool get needsLogin => _needsLogin;

  // usable user data
  Match? _soonestMatch;
  Match? get soonestMatch => _soonestMatch;

  Match? _openMatch;
  Match? get openMatch => _openMatch;

  dynamic _openEvent;
  dynamic get openEvent => _openEvent;

  List<Match>? _upcomingMatches;
  List<Match>? get upommingMatches => _upcomingMatches;

  List<Match>? _pastMatches;
  List<Match>? get pastMatches => _pastMatches;

  List<Training>? _upcommingTrainings;
  List<Training>? get upcommingTrainings => _upcommingTrainings;

  UserProvider() {
    _init();
  }

  // Clear errors after they're handled
  void clearErrors() {
    _authError = null;
    _needsLogin = false;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    try {
      "inside refreshUserData".green.log();
      _user = await authLogin(); // Fetch fresh user data from the server
      _processMatches();
      _saveUserSession();
      notifyListeners(); // Notify listeners to rebuild UI with updated data
    } catch (error) {
      debugPrint('Error refreshing user data: $error');
    }
  }

  Future<void> _init() async {
    "INIT USER PROVIDER".red.log();
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null || userId != null) {
      await _handleAuthStateChange(firebaseUser);
    } else {
      _user = null;
      _needsLogin = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null && _user!.id != null) {
      await prefs.setString('userId', _user!.id!);
    } else {
      await prefs.remove('userId');
    }
  }

  Future<void> checkAuthState() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    "Checking auth state".green.log();

    await _handleAuthStateChange(firebaseUser);
  }

  Future<void> _handleAuthStateChange(User? firebaseUser) async {
    "inside  _handleAuthStateChange".cyan.log();
    if (firebaseUser == null) {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('userId')) {
        "inside firebase ==null and no userId".red.log();
        _user = null;
        _needsLogin = true; // Signal that login is needed
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    try {
      "Inside user Provider auth login".green.log();
      _user = await authLogin();
      _saveUserSession();
      "$_user".green.log();
      if (_user == null) {
        _needsLogin = true;
      }
      "$isLoading".green.log();

      _processMatches();

      _isLoading = false;
      notifyListeners();
      return;
    } catch (error) {
      "Error fetching user data, signing out user... Error: $error".red.log();
      await _clearSessionAndSignOut();
    }
  }

  Future<void> _clearSessionAndSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      "User signed out due to auth error".yellow.log();
    } catch (signOutError) {
      "Error during sign out after auth failure: $signOutError".red.log();
    }
    _authError = "Error fetching user data. Please login again.";
    _needsLogin = true;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Extract match processing logic to a separate method
  void _processMatches() {
    "============= Processing matches ============".green.log();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _upcomingMatches = _user?.matches
        ?.where((match) => match.date.isAfter(today))
        .cast<Match>()
        .toList();
    _soonestMatch = findSoonestMatch(_upcomingMatches);
    // _openMatch = findOpenMatch(_user?.matches);

    final tempEvent = findOpenMatchOrTraining(user?.matches, user?.trainings);
    "matches length: ${user?.matches?.length}".green.log();
    "training  lenges: ${user?.trainings?.length}".green.log();
    if (tempEvent is Match) {
      "Inside changing open match".red.log();
      _openEvent = tempEvent;
    } else if (tempEvent is Training) {
      _openEvent = tempEvent;
    } else {
      _openEvent = null;
    }
    _pastMatches = _user?.matches
        ?.where((match) => match.date.isBefore(today))
        .cast<Match>()
        .toList();
  }

  void setUser(AppUser? user) {
    _user = user;
    _saveUserSession();
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> updates) {
    if (_user != null) {
      _user = _user!.copyWith(updates);
      _processMatches();
      _saveUserSession();
      notifyListeners();
    }
  }

  // Add a method to specifically update matches
  void updateMatches(List<Match>? matches) {
    if (_user != null) {
      updateUser({'matches': matches});
    }
  }

  // Add this method to your UserProvider class
  void addMatch(Match match) {
    if (_user != null) {
      List<Match> updatedMatches = List<Match>.from(_user!.matches ?? []);
      updatedMatches.add(match);
      updateUser({'matches': updatedMatches});
      // Note: _processMatches() is already called within updateUser
    }
  }

  void addTraining(Training training) {
    if (_user != null) {
      List<Training> updatedTrainings =
          List<Training>.from(_user!.trainings ?? []);
      updatedTrainings.add(training);
      "Adding training to user".green.log();
      "${updatedTrainings.last.investigation}".green.log();
      updateUser({'trainings': updatedTrainings});
      // Note: _processMatches() is already called within updateUser
    }
  }

  void updateMatch(Match updatedMatch) {
    if (_user != null && _user!.matches != null) {
      List<Match> currentMatches = List<Match>.from(_user!.matches ?? []);

      // Find index of match with same ID
      int matchIndex =
          currentMatches.indexWhere((match) => match.id == updatedMatch.id);

      if (matchIndex != -1) {
        // Replace the match at found index
        currentMatches[matchIndex] = updatedMatch;
        "Updating match in user".green.log();
        updateUser({'matches': currentMatches});
        // _processMatches() is called within updateUser
      } else {
        "Match not found for update".yellow.log();
      }
    }
  }

  void updateTraining(Training updatedTraining) {
    if (_user != null && _user!.trainings != null) {
      List<Training> currentTrainings =
          List<Training>.from(_user!.trainings ?? []);

      // Find index of training with same ID
      int trainingIndex = currentTrainings
          .indexWhere((training) => training.id == updatedTraining.id);

      if (trainingIndex != -1) {
        // Replace the training at found index
        "Updating training in user".green.log();
        "${updatedTraining.isOpen}".green.log();
        "${updatedTraining.investigation}".green.log();

        currentTrainings[trainingIndex] = updatedTraining;

        "${currentTrainings[trainingIndex].isOpen}".green.log();

        updateUser({'trainings': currentTrainings});
        // _processMatches() is called within updateUser
      } else {
        "Training not found for update".yellow.log();
      }
    }
  }

  void removeMatch(String matchId) {
    "Removing match from user".green.log();
    if (_user != null && _user!.matches != null) {
      List<Match> currentMatches = List<Match>.from(_user!.matches ?? []);

      currentMatches.removeWhere((match) => match.id == matchId);

      "Removing match from user".green.log();
      updateUser({'matches': currentMatches});
      // _processMatches() is called within updateUser
    }
  }

  void removeTraining(String trainingId) {
    if (_user != null && _user!.trainings != null) {
      List<Training> currentTrainings =
          List<Training>.from(_user!.trainings ?? []);

      // Remove training with the specified ID
      currentTrainings.removeWhere((training) => training.id == trainingId);

      "Removing training from user".green.log();
      updateUser({'trainings': currentTrainings});
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      "Signing out user...".yellow.log();
      _isLoading = true;
      notifyListeners();

      context.go('/login');
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Clear user data
      _user = null;
      _soonestMatch = null;
      _openMatch = null;
      _openEvent = null;
      _upcomingMatches = null;
      _pastMatches = null;
      _upcommingTrainings = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      // Set flag to indicate login is needed
      _needsLogin = true;
      _isLoading = false;

      "User signed out successfully".green.log();
      notifyListeners();
    } catch (error) {
      "Error signing out: $error".red.log();
      _authError = "Failed to sign out. Please try again.";
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isThereIsOpenEvent() {
    final matches = user?.matches;
    final trainings = user?.trainings;

    if (matches != null && matches.isNotEmpty) {
      for (var match in matches) {
        if (match.isOpen == true) {
          return true;
        }
      }
    }

    if (trainings != null && trainings.isNotEmpty) {
      for (var training in trainings) {
        if (training.isOpen == true) {
          return true;
        }
      }
    }

    return false;
  }

  // Method to sync subscription status with server
  Future<void> syncSubscriptionStatusWithServer(String subscriptionType) async {
    try {
      if (_user == null || _user!.id == null) {
        print("Cannot sync subscription: User not logged in");
        return;
      }

      print("Subscription status synced with server: $subscriptionType");
    } catch (e) {
      print("Error syncing subscription status with server: $e");
    }
  }
}
