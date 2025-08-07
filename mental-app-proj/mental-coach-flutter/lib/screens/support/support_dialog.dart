import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/service/support_service.dart';
import 'package:mental_coach_flutter_firebase/widgets/buttons/app_button.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_subtitle.dart';
import 'package:mental_coach_flutter_firebase/widgets/app_form_field.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:provider/provider.dart';
import 'package:mental_coach_flutter_firebase/providers/user_provider.dart';

class SupportDialog extends StatefulWidget {
  final String currentPage;
  final String? openDialog;

  const SupportDialog({
    super.key,
    required this.currentPage,
    this.openDialog,
  });

  @override
  SupportDialogState createState() => SupportDialogState();
}

class SupportDialogState extends State<SupportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _selectedCategory;

  final List<String> _categories = [
    'תקלה טכנית',
    'בעיה בתצוגה',
    'בעיה בתשלום',
    'הצעה לשיפור',
    'אחר',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendSupportRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('לא ניתן לשלוח פנייה ללא משתמש מחובר'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // בניית הנושא הסופי
    final finalSubject = _selectedCategory != null
        ? '$_selectedCategory: ${_subjectController.text}'
        : _subjectController.text;

    // שליחת הפנייה
    final success = await SupportService.sendSupportRequest(
      subject: finalSubject,
      description: _descriptionController.text,
      userEmail: user.email ?? '',
      userName: '${user.firstName} ${user.lastName}'.trim(),
      currentPage: widget.currentPage,
      openDialog: widget.openDialog,
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הפנייה נשלחה בהצלחה! נחזור אליך בהקדם'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('שגיאה בשליחת הפנייה. אנא נסה שנית'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: screenWidth > 500 ? 500 : screenWidth * 0.9,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // כותרת
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppSubtitle(
                    subTitle: 'פנייה לתמיכה',
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // תוכן הטופס
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // בחירת קטגוריה
                      AppSubtitle(
                        subTitle: 'קטגוריה',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            hint: const Text('בחר קטגוריה'),
                            isExpanded: true,
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // נושא הפנייה
                      AppSubtitle(
                        subTitle: 'נושא הפנייה',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      AppFormField(
                        controller: _subjectController,
                        textHint: 'תאר בקצרה את הבעיה',
                        validationMessage: 'אנא הזן נושא לפנייה',
                        borderRadius: 10,
                      ),
                      const SizedBox(height: 20),

                      // תיאור מפורט
                      AppSubtitle(
                        subTitle: 'תיאור מפורט',
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'פרט את הבעיה שנתקלת בה...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'אנא תאר את הבעיה';
                          }
                          if (value.length < 10) {
                            return 'התיאור צריך להכיל לפחות 10 תווים';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      
                      // הערה על המידע שיישלח
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, 
                                color: Colors.blue.shade700, 
                                size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'המידע הטכני על המכשיר והעמוד הנוכחי יישלח אוטומטית כדי לעזור לנו לפתור את הבעיה',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // כפתורים
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'ביטול',
                      action: 'support_dialog_cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey,
                      borderRadius: 10,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _isLoading ? 'שולח...' : 'שלח פנייה',
                      action: 'support_dialog_send',
                      onPressed: _isLoading ? null : _sendSupportRequest,
                      color: AppColors.primary,
                      borderRadius: 10,
                      isLoading: _isLoading,
                      disabled: _isLoading,
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