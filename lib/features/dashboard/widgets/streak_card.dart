import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({Key? key, required this.streakDays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayLabel = streakDays == 1 ? 'día' : 'días';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$dayLabel de racha',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.92),
                ),
              ),
            ],
          ),
          if (streakDays > 0) ...[
            const SizedBox(width: 10),
            const Icon(Icons.check_circle, size: 18, color: Colors.white),
          ],
        ],
      ),
    );
  }
}
