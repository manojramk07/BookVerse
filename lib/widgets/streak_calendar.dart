import 'package:flutter/material.dart';

import '../services/app_state.dart';

class StreakCalendar extends StatelessWidget {
  const StreakCalendar({
    super.key,
    required this.month,
    required this.readingDays,
  });

  final DateTime month;
  final Set<String> readingDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingDays = firstDay.weekday - DateTime.monday;
    final cells = <Widget>[];
    const weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    for (final label in weekdayLabels) {
      cells.add(
        Center(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    for (var index = 0; index < leadingDays; index++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isFuture = date.isAfter(DateTime.now());
      final isToday = _dayKey(date) == _dayKey(DateTime.now());
      final hasRead = readingDays.contains(_dayKey(date));
      final tileColor = isFuture
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : hasRead
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest;
      final dateColor = isFuture
          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
          : theme.colorScheme.onSurface;
      cells.add(
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(color: dateColor, fontWeight: FontWeight.w600),
              ),
              if (hasRead && !isFuture) ...[
                const SizedBox(width: 3),
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_monthName(month.month)} ${month.year}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 9,
          crossAxisSpacing: 7,
          childAspectRatio: 1.05,
          children: cells,
        ),
      ],
    );
  }

  String _dayKey(DateTime date) => AppState.dayKey(date);

  String _monthName(int month) => const [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month];
}
