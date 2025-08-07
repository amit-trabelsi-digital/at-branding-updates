import 'package:flutter/material.dart';

class AppDropdownButtonFormField<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final IconData? icon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;

  const AppDropdownButtonFormField({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon = Icons.arrow_drop_down,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.textStyle = const TextStyle(fontSize: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: contentPadding,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            focusedBorder: OutlineInputBorder(
                // borderSide: BorderSide(color: selectedColor!, width: 2),
                ),
          ),
          style: textStyle,
          items: items,
        ),
      ],
    );
  }
}
