import 'package:flutter/material.dart';

class DropdownAction<T> {
  final String label;
  final T value;
  final IconData? icon;

  const DropdownAction({
    required this.label,
    required this.value,
    this.icon,
  });
}

class AppDropdownActionButton<T> extends StatelessWidget {
  final List<DropdownAction<T>> items;
  final Function(T) onSelected;
  final Widget? child;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const AppDropdownActionButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.child,
    this.icon = Icons.more_vert,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      icon: icon != null
          ? Icon(
              icon,
              color: iconColor,
              size: iconSize,
            )
          : null,
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon),
                    const SizedBox(width: 8),
                  ],
                  Text(item.label),
                ],
              ),
            ),
          )
          .toList(),
      child: child,
    );
  }
}
