import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class AppAutocompleteFormField<T extends Object> extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final T? value;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final bool secondeyStyle;
  final bool isListField;
  final VoidCallback? onRemove;
  final bool allowCustomValues; // Add this parameter
  final T Function(String)?
      customValueCreator; // Add this parameter to convert string to T

  const AppAutocompleteFormField({
    super.key,
    this.title,
    this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
    this.secondeyStyle = false,
    this.isListField = false,
    this.validator,
    this.icon = Icons.arrow_drop_down,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.textStyle = const TextStyle(fontSize: 16),
    this.onRemove,
    this.allowCustomValues = false, // Default to false
    this.customValueCreator, // Function to create a new T object from string
  }) : assert(
          !allowCustomValues || customValueCreator != null,
          'customValueCreator must be provided when allowCustomValues is true',
        );

  @override
  Widget build(BuildContext context) {
    final Image arrowIcon = Image.asset(
      'icons/arrow-down-icon.png', // Active state image
      width: 24,
      height: 24,
    );

    var borderRadius =
        secondeyStyle ? BorderRadius.circular(8) : BorderRadius.circular(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        const SizedBox(height: 8),
        Autocomplete<T>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return options;
            }

            final String query = textEditingValue.text.toLowerCase();
            final List<String> queryWords =
                query.split(' ').where((s) => s.isNotEmpty).toList();

            // Different matching strategies with priority order
            final List<T> exactMatches = [];
            final List<T> startsWithMatches = [];
            final List<T> containsMatches = [];
            final List<T> wordMatches = [];

            for (final T option in options) {
              final String optionText = option.toString().toLowerCase();
              final List<String> optionWords =
                  optionText.split(' ').where((s) => s.isNotEmpty).toList();

              if (optionText == query) {
                exactMatches.add(option);
              } else if (optionText.startsWith(query)) {
                startsWithMatches.add(option);
              } else if (optionText.contains(query)) {
                containsMatches.add(option);
              } else {
                // Check if any word in the option starts with any word in the query
                bool hasWordMatch = false;
                for (final String queryWord in queryWords) {
                  for (final String optionWord in optionWords) {
                    if (optionWord.startsWith(queryWord)) {
                      hasWordMatch = true;
                      break;
                    }
                  }
                  if (hasWordMatch) break;
                }

                if (hasWordMatch) {
                  wordMatches.add(option);
                }
              }
            }

            // Combine results in priority order
            return [
              ...exactMatches,
              ...startsWithMatches,
              ...containsMatches,
              ...wordMatches,
            ];
          },
          displayStringForOption: (T option) => option.toString(),
          onSelected: onChanged,
          optionsViewBuilder: (context, onSelected, options) {
            // Check if keyboard is visible
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final isKeyboardVisible = keyboardHeight > 0;

            return Align(
              alignment: isKeyboardVisible
                  ? Alignment.bottomRight
                  : Alignment.topRight,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: secondeyStyle
                        ? MediaQuery.of(context).size.width * 0.88
                        : MediaQuery.of(context).size.width * 0.78,
                    maxHeight: isKeyboardVisible
                        ? 120
                        : 160, // Smaller height when keyboard is visible
                  ),
                  child: Container(
                    margin: isKeyboardVisible
                        ? EdgeInsets.only(bottom: 8)
                        : EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final T option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option.toString()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Initialize the text controller with the value
            if (value != null && textEditingController.text.isEmpty) {
              textEditingController.text = value.toString();
            }

            // Add listener for focus changes to handle keyboard
            focusNode.addListener(() {
              if (focusNode.hasFocus) {
                // Ensure the field is visible when keyboard appears
                Future.delayed(const Duration(milliseconds: 300), () {
                  Scrollable.ensureVisible(
                    context,
                    alignment: 0.1, // Position field near top of screen
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (value) {
                // Handle custom value submission
                if (allowCustomValues &&
                    customValueCreator != null &&
                    !options.any((option) =>
                        option.toString().toLowerCase() ==
                        value.toLowerCase())) {
                  // Create and add a custom value
                  final customValue = customValueCreator!(value);
                  onChanged(customValue);
                }
                onFieldSubmitted();
              },
              decoration: InputDecoration(
                contentPadding: secondeyStyle
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 23)
                    : contentPadding,
                hintText: allowCustomValues ? "בחר או כתוב בעצמך" : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                      color: secondeyStyle
                          ? AppColors.borderGrey
                          : AppColors.borderGrey,
                      width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: !isListField
                      ? arrowIcon
                      : GestureDetector(
                          onTap: onRemove ??
                              () {
                                textEditingController.clear();
                                onChanged(null);
                              },
                          child: textEditingController.text.isEmpty
                              ? arrowIcon
                              : Icon(Icons.delete_outline_outlined)),
                ),
              ),
              style: textStyle,
              validator: (value) {
                if (value != null && validator != null) {
                  if (allowCustomValues) {
                    // If custom values are allowed, we can pass a custom value to the validator
                    final matchedOption = options.cast<T?>().firstWhere(
                          (option) =>
                              option?.toString().toLowerCase() ==
                              value.toLowerCase(),
                          orElse: () => customValueCreator != null
                              ? customValueCreator!(value) as T?
                              : null,
                        );
                    return validator!(matchedOption);
                  } else {
                    // Check if the value matches an option in the list
                    final matchedOption = options.cast<T?>().firstWhere(
                          (option) =>
                              option?.toString().toLowerCase() ==
                              value.toLowerCase(),
                          orElse: () => null as T?,
                        );
                    return validator!(matchedOption);
                  }
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }
}
