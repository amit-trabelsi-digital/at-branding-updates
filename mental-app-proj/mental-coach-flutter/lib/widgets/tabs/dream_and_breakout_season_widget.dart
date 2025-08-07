import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';

class DreamAndBreakoutSeasonWidget extends StatefulWidget {
  final String dreamTitle;
  final String dreamDescription;
  final String breakoutTitle;
  final String breakoutDescription;

  const DreamAndBreakoutSeasonWidget({
    super.key,
    required this.dreamTitle,
    required this.dreamDescription,
    required this.breakoutTitle,
    required this.breakoutDescription,
  });

  @override
  State<DreamAndBreakoutSeasonWidget> createState() =>
      _DreamAndBreakoutSeasonWidgetState();
}

class _DreamAndBreakoutSeasonWidgetState
    extends State<DreamAndBreakoutSeasonWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab(0, widget.breakoutTitle, Icons.emoji_events_outlined),
              const SizedBox(width: 16),
              _buildTab(1, widget.dreamTitle, Icons.cloud_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _selectedIndex == 0
                ? widget.breakoutDescription
                : widget.dreamDescription,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Container(
             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
