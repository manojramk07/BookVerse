import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/streak_calendar.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Streak')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _StreakSummary(
            currentStreak: state.currentStreak,
            bestStreak: state.bestStreak,
          ),
          const SizedBox(height: 20),
          StreakCalendar(
            month: DateTime(now.year, now.month),
            readingDays: state.readingDays,
          ),
          const SizedBox(height: 20),
          StreakCalendar(
            month: DateTime(now.year, now.month - 1),
            readingDays: state.readingDays,
          ),
        ],
      ),
    );
  }
}

class _StreakSummary extends StatelessWidget {
  const _StreakSummary({required this.currentStreak, required this.bestStreak});

  final int currentStreak;
  final int bestStreak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 34,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak day streak',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Best streak: $bestStreak days'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
