import 'package:flutter/material.dart';
import 'package:mental_coach_flutter_firebase/data/lists.dart';
import 'package:mental_coach_flutter_firebase/widgets/cards/app_card.dart';

class AppGoalsCard extends StatefulWidget {
  final String dreamText;
  final String breakOutSeasonText;
  final IconData icon;

  const AppGoalsCard({
    super.key,
    required this.dreamText,
    required this.breakOutSeasonText,
    this.icon = Icons.person_outline,
  });

  @override
  _AppGoalsCardState createState() => _AppGoalsCardState();
}

class _AppGoalsCardState extends State<AppGoalsCard> {
  bool _isDreamTabActive = true;

  Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.white : AppColors.darkergrey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab('החלום הגדול שלי', _isDreamTabActive, () {
                setState(() {
                  _isDreamTabActive = true;
                });
              }),
              _buildTab('עונת הפריצה שלי', !_isDreamTabActive, () {
                setState(() {
                  _isDreamTabActive = false;
                });
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 73,
                height: 73,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _isDreamTabActive
                          ? 'icons/leafs-icon.png'
                          : 'icons/cup-icon.png',
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 60, // Minimum height to prevent layout shifts
                  ),
                  child: Text(
                    _isDreamTabActive ? widget.dreamText : widget.breakOutSeasonText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.darkergrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
