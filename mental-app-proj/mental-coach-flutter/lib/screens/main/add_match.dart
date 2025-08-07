import 'dart:convert';

import 'package:color_simp/color_simp.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/helpers/helpers.dart';
import 'package:mental_coach_flutter_firebase/models/model.dart';
import 'package:mental_coach_flutter_firebase/providers/data_provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_auto_complete.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_title.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_datecard.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_toggle_buttons.dart';
import 'package:mental_coach_flutter_firebase/widgets/layouts/top_image_layout.dart';
import 'package:provider/provider.dart';

class AddMatch extends StatefulWidget {
  final String? status;
  final String? matchId; // For editing existing match
  const AddMatch({super.key, this.status, this.matchId});

  @override
  State<AddMatch> createState() => _AddMatchState();
}

class _AddMatchState extends State<AddMatch> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  bool isUserPickedTime = false; // Track if user explicitly selected a date
  int _selectedIndex = 0; // 0 for home, 1 for away
  dynamic _selectedTeam;
  dynamic _selectedCustomTeam;
  String? _selectedLocation;
  final userProvider = UserProvider();
  bool isThereIsEmptyEvent = false;
  Match? existingMatch; // For editing mode
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    if (widget.matchId != null) {
      // Get match from user provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      
      Match? match;
      try {
        match = userProvider.user?.matches?.firstWhere(
          (m) => m.id == widget.matchId,
        );
      } catch (e) {
        // Match not found
        match = null;
      }
      
      if (match != null) {
        final matchData = match;  // Create final variable for use in setState
        setState(() {
          existingMatch = matchData;
          selectedDate = matchData.date ?? DateTime.now();
          isUserPickedTime = matchData.isUserPickedTime ?? false;
          
          // Set home/away status
          final userTeamId = userProvider.user?.team?.id ?? userProvider.user?.userTeam?.name;
          _selectedIndex = matchData.homeTeam == userTeamId ? 0 : 1;
          
          // Set opposing team
          final opposingTeamId = _selectedIndex == 0 ? matchData.awayTeam : matchData.homeTeam;
          
          // Try to find team in data provider
          Team? team;
          try {
            team = dataProvider.teams.firstWhere(
              (t) => t.id == opposingTeamId,
            );
          } catch (e) {
            // Team not found in list
            team = null;
          }
          
          if (team != null) {
            _selectedTeam = team.name;
          } else {
            // It's a custom team name
            _selectedCustomTeam = opposingTeamId;
          }
        });
      }
    }
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // If there's an empty event, don't allow dates before today
      firstDate: isThereIsEmptyEvent ? DateTime.now() : DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (picked != null) {
      setState(() {
        isUserPickedTime = true; // User has explicitly picked a date

        // Update the selectedDate to include the selected time
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void handleSubmit() async {
    if (widget.status == 'training' || _formKey.currentState!.validate()) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final userTeam = userProvider.user?.team?.id ??
          userProvider.user?.userTeam?.name ??
          '';

      Map<String, dynamic> requestBody = {
        'date': selectedDate.toIso8601String(),
        'isUserPickedTime': isUserPickedTime,
      };
      // Only add team-related fields for matches (not training)
      if (widget.status == 'match') {
        String vsTeam;
        if (_selectedTeam != null) {
          vsTeam = dataProvider.teams
                  .firstWhere((team) => team.name == _selectedTeam)
                  .id ??
              ''; // Get team id from name and handle null
        } else {
          vsTeam = _selectedCustomTeam ?? '';
        }

        final String homeTeam = _selectedIndex == 0 ? userTeam : vsTeam;
        final String awayTeam = _selectedIndex == 1 ? userTeam : vsTeam;

        requestBody.addAll({
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'isHomeMatch': _selectedIndex == 0 ? true : false,
        });
      }

      try {
        // Determine if we're creating or updating
        final bool isEditing = widget.matchId != null;
        final url = isEditing 
            ? '/matches/${widget.matchId}'
            : '/matches${widget.status == 'training' ? '/training' : ''}';
        final method = isEditing ? 'PUT' : 'POST';
        
        final response = await AppFetch.fetch(url,
            method: method,
            headers: {'Custom-Header': 'Value'},
            body: requestBody);

        if (response.statusCode == 200 || response.statusCode == 201) {
          'Response data from add_match : ${response.body}'.yellow.log();

          // Parse the match and update
          if (widget.status == 'match') {
            final Match updatedMatch = Match.fromJson(jsonDecode(response.body));
            
            if (isEditing) {
              // Update existing match in user provider
              userProvider.updateMatch(updatedMatch);
            } else {
              // Add new match
              userProvider.addMatch(updatedMatch);
            }
            
            if (mounted) {
              final String route = isWithin24Hours(updatedMatch.date)
                  ? '/match-prepare/${updatedMatch.id}'
                  : '/dashboard/4';

              context.go(route);
            }
          } else {
            final Training newTraining =
                Training.fromJson(jsonDecode(response.body));
            userProvider.addTraining(newTraining);
            if (mounted) {
              final String route = isWithin24Hours(newTraining.date)
                  ? '/training-prepare/${newTraining.id}'
                  : '/dashboard/4';

              context.go(route);
            }
          }
        } else {
          print('Error: ${response.statusCode}, ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    isThereIsEmptyEvent = userProvider.isThereIsOpenEvent();

    final List<Team> updatedTeams = dataProvider.teams
        .where((team) => team.id != userProvider.user?.team?.id)
        .toList(); // Remove user's team from the list

    const double cardPadding = 18;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final bool isEditing = widget.matchId != null;
    final String titlePrefix = isEditing ? 'עריכת' : 'הוספת';
    
    if (isLoading) {
      return TopImageLayout(
        title: titlePrefix + ' ${widget.status == 'training' ? 'אימון' : 'משחק'}',
        imageSrc: 'images/match_banner.png',
        formKey: _formKey,
        cardChildren: [
          Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
        additionalChildren: [],
      );
    }

    return TopImageLayout(
      title: titlePrefix + ' ${widget.status == 'training' ? 'אימון' : 'משחק'}',
      imageSrc: 'images/match_banner.png',
      formKey: _formKey,
      cardChildren: [
        AppSubtitle(
          subTitle:
              'מתי ${widget.status == 'training' ? 'מתאמנים' : 'משחקים'}?',
          textAlign: TextAlign.start,
          fontSize: 20,
          verticalMargin: 8,
        ),
        Align(
          alignment: Alignment.center,
          child: DateCard(
            date: selectedDate.day.toString(),
            day: WEEK_DAYS[selectedDate.weekday - 1],
            month: MONTHS[selectedDate.month - 1],
          ),
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screenWidth / 2,
            child: AppButton(
              fontSize: 20,
              action: '0009 , Click , Select Date',
              onPressed: () => _selectDate(context),
              label: 'בחר תאריך',
            ),
          ),
        ),
        SizedBox(height: 10),
        AppSubtitle(
          subTitle: 'בחר שעה (אופציונלי)',
          textAlign: TextAlign.start,
          fontSize: 20,
          verticalMargin: 8,
        ),
        if (isUserPickedTime)
          Center(
              child: AppTitle(
                  lineHeight: 0.8,
                  verticalMargin: 3,
                  title:
                      '${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}')),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screenWidth / 2,
            child: AppButton(
              fontSize: 20,
              action: '0011 , Click , Select Time',
              onPressed: () => _selectTime(context),
              label: 'בחר שעה',
            ),
          ),
        ),
        SizedBox(height: 20),
        if (widget.status != 'training') ...[
          AppAutocompleteFormField<String>(
            title: 'נגד מי?',
            value: _selectedTeam,
            options: updatedTeams
                .map((team) {
                  return team.name ?? '';
                })
                .where((name) => name.isNotEmpty)
                .toList(),
            allowCustomValues: true,
            customValueCreator: (String teamName) {
              setState(() {
                _selectedTeam = null;
                _selectedCustomTeam = teamName;
              });
              return teamName;
            },
            onChanged: (value) {
              setState(() {
                _selectedTeam = value;
              });
            },
            validator: (value) {
              if (value == null || value.toString().trim().isEmpty) {
                return 'נא לבחור או להזין קבוצה';
              }
              return null;
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          SizedBox(height: 20),
          AppSubtitle(
            subTitle: 'איפה משחקים?',
            textAlign: TextAlign.start,
            fontSize: 20,
            verticalMargin: 8,
          ),
          Center(
            child: AppToggleButtons(
              isSelected: [_selectedIndex == 0, _selectedIndex == 1],
              onPressed: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              screenWidth: screenWidth - cardPadding,
              labels: [' משחק חוץ', ' משחק בית'],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ]
      ],
      additionalChildren: [
        Column(
          children: [
            SizedBox(height: 40),
            AppButton(
              action:
                  '0010 , Click , ${isEditing ? 'Update' : 'Add'} ${widget.status == 'training' ? 'training' : 'match'}',
              pHeight: 15,
              onPressed: () {
                handleSubmit();
              },
              label: '${isEditing ? 'עדכן' : 'הוסף'}  ${widget.status == 'training' ? 'אימון' : 'משחק'}',
            ),
          ],
        ),
      ],
    );
  }
}
