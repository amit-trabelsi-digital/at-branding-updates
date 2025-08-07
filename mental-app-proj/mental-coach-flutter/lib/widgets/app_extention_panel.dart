import 'package:flutter/material.dart';

class CustomExpansionPanel extends StatefulWidget {
  final String title;
  final Widget body;
  final Color titleColor;
  final TextStyle? titleStyle;

  const CustomExpansionPanel({
    super.key,
    required this.title,
    required this.body,
    this.titleColor = Colors.blue,
    this.titleStyle,
  });

  @override
  CustomExpansionPanelState createState() => CustomExpansionPanelState();
}

class CustomExpansionPanelState extends State<CustomExpansionPanel> {
  final bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 1,
      expandedHeaderPadding: EdgeInsets.all(0),
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              title: Text(
                widget.title,
                style: widget.titleStyle ??
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.titleColor,
                    ),
              ),
            );
          },
          body: widget.body,
          isExpanded: _isExpanded,
        ),
      ],
    );
  }
}
