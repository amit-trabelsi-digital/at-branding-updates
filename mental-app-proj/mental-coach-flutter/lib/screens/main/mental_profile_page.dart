import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/service/api_service.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_loading_indicator.dart';
import 'package:intl/intl.dart';

class MentalProfilePage extends StatefulWidget {
  const MentalProfilePage({Key? key}) : super(key: key);

  @override
  State<MentalProfilePage> createState() => _MentalProfilePageState();
}

class _MentalProfilePageState extends State<MentalProfilePage> {
  List<Map<String, dynamic>> _responses = [];
  bool _isLoading = true;
  String? _selectedProgram;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);

    try {
      final responses = await TrainingApiService.getUserExerciseResponses();
      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בטעינת התשובות: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get filteredResponses {
    return _responses.where((response) {
      final matchProgram = _selectedProgram == null ||
          response['programTitle'] == _selectedProgram;
      final matchType =
          _selectedType == null || response['exerciseType'] == _selectedType;
      return matchProgram && matchType;
    }).toList();
  }

  Set<String> get availablePrograms {
    return _responses.map((r) => r['programTitle'] as String).toSet();
  }

  Set<String> get availableTypes {
    return _responses.map((r) => r['exerciseType'] as String).toSet();
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'questionnaire':
        return 'שאלון';
      case 'text_input':
        return 'טקסט חופשי';
      case 'video_reflection':
        return 'רפלקציה על וידאו';
      case 'action_plan':
        return 'תוכנית פעולה';
      case 'mental_visualization':
        return 'ויזואליזציה מנטלית';
      case 'content_slider':
        return 'תוכן אינטראקטיבי';
      default:
        return type;
    }
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // סינון לפי תוכנית
        if (availablePrograms.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'סנן לפי תוכנית:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('הכל'),
                  selected: _selectedProgram == null,
                  onSelected: (_) => setState(() => _selectedProgram = null),
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(
                    color:
                        _selectedProgram == null ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ...availablePrograms.map((program) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(program),
                        selected: _selectedProgram == program,
                        onSelected: (selected) => setState(() {
                          _selectedProgram = selected ? program : null;
                        }),
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: _selectedProgram == program
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],

        // סינון לפי סוג תרגיל
        if (availableTypes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'סנן לפי סוג תרגיל:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('הכל'),
                  selected: _selectedType == null,
                  onSelected: (_) => setState(() => _selectedType = null),
                  selectedColor: AppColors.secondary,
                  labelStyle: TextStyle(
                    color: _selectedType == null ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                ...availableTypes.map((type) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(_getTypeDisplayName(type)),
                        selected: _selectedType == type,
                        onSelected: (selected) => setState(() {
                          _selectedType = selected ? type : null;
                        }),
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: _selectedType == type
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> response) {
    final completedAt = response['completedAt'] != null
        ? DateTime.parse(response['completedAt'])
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // כותרת
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response['exerciseTitle'] ?? 'תרגיל ללא שם',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${response['programTitle']} - שיעור ${response['lessonNumber']}: ${response['lessonTitle']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getTypeDisplayName(response['exerciseType'] ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // תוכן התשובה
            _buildResponseContent(response),

            const SizedBox(height: 12),

            // מידע נוסף
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (completedAt != null)
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(completedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (response['score'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ניקוד: ${response['score']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseContent(Map<String, dynamic> response) {
    final type = response['exerciseType'];
    final userResponses = response['responses'] ?? {};
    final content = response['exerciseContent'] ?? {};

    switch (type) {
      case 'questionnaire':
        final questions = content['questions'] as List<dynamic>? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.map((question) {
            final qId = question['id'] ?? '';
            final userAnswer = userResponses[qId];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'שאלה: ${question['question'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'תשובה: ${userAnswer ?? 'לא נענה'}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'text_input':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['question'] ?? 'שאלה',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                userResponses['answer'] ?? 'לא נענה',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        );

      case 'action_plan':
        final steps = userResponses['steps'] as List<dynamic>? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'תוכנית הפעולה שלי:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          step.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );

      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            userResponses.toString(),
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // const CustomBackBtn(), - קומפוננטה לא קיימת
                  const SizedBox(width: 16),
                  const Text(
                    'הפרופיל המנטלי שלי',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: AppLoadingIndicator())
                  : _responses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'עדיין לא ענית על תרגילים',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'התחל ללמוד בתוכניות האימון המנטלי\nכדי לבנות את הפרופיל שלך',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            if (_responses.isNotEmpty) ...[
                              _buildFilterChips(),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'סה"כ ${filteredResponses.length} תשובות',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _loadResponses,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: filteredResponses.length,
                                  itemBuilder: (context, index) {
                                    return _buildResponseCard(
                                        filteredResponses[index]);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
