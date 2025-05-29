import 'package:flutter/material.dart';

class DayStreakBadge extends StatelessWidget {
  final int day;
  final bool completed;
  final bool isToday;
  final Color doraemonBlue;
  final Color doraemonRed;

  const DayStreakBadge({
    super.key,
    required this.day,
    required this.completed,
    required this.doraemonBlue,
    required this.doraemonRed,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageAsset = completed
        ? 'assets/images/doraemon_happy.png'
        : 'assets/images/doraemon_sad.png';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday ? Colors.green : Colors.transparent,
              width: 2,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Image.asset(
            imageAsset,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: -10, // pushed further out
          right: -10, // pushed further out
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                )
              ],
            ),
            child: Text(
              '$day',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
