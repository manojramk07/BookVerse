import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../widgets/streak_calendar.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final now = DateTime.now();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedRecord = state.getReadingRecordForDate(_selectedDate);

    // List of days with real activity sorted descending
    final activeDates = state.dailyReadingRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Streak & Activity'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _StreakSummary(
            currentStreak: state.currentStreak,
            bestStreak: state.bestStreak,
            totalReadingSeconds: state.totalReadingSeconds,
          ),
          const SizedBox(height: 18),

          // Real-time Daily Reading Breakdown Card for Selected Date
          _buildDailyActivityCard(
            context,
            date: _selectedDate,
            record: selectedRecord,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Interactive Streak Calendar
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Color(0xFF5E35B1), size: 22),
              const SizedBox(width: 8),
              Text(
                'Reading Streak Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any date to inspect reading time and books read.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          StreakCalendar(
            month: DateTime(now.year, now.month),
            readingDays: state.readingDays,
            selectedDate: _selectedDate,
            onSelectDate: (date) => setState(() => _selectedDate = date),
            dailyRecords: state.dailyReadingRecords,
          ),
          const SizedBox(height: 20),
          StreakCalendar(
            month: DateTime(now.year, now.month - 1),
            readingDays: state.readingDays,
            selectedDate: _selectedDate,
            onSelectDate: (date) => setState(() => _selectedDate = date),
            dailyRecords: state.dailyReadingRecords,
          ),

          if (activeDates.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.history_edu_rounded, color: Color(0xFFD97706), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Daily Reading Log',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeDates.map((dateKey) {
              final record = state.dailyReadingRecords[dateKey]!;
              final isCurrentSelected = AppState.dayKey(_selectedDate) == dateKey;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isCurrentSelected
                      ? const Color(0xFF5E35B1).withValues(alpha: isDark ? 0.25 : 0.08)
                      : (isDark ? const Color(0xFF1E1B2E) : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentSelected
                        ? const Color(0xFF5E35B1)
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    width: isCurrentSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.18),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateKey,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E35B1).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppState.formatDuration(record.seconds),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E35B1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: record.bookTitles.isNotEmpty
                        ? Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: record.bookTitles.map((title) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : const Text(
                            'Session recorded',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                  ),
                  onTap: () {
                    try {
                      final parts = dateKey.split('-');
                      if (parts.length == 3) {
                        setState(() {
                          _selectedDate = DateTime(
                            int.parse(parts[0]),
                            int.parse(parts[1]),
                            int.parse(parts[2]),
                          );
                        });
                      }
                    } catch (_) {}
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyActivityCard(
    BuildContext context, {
    required DateTime date,
    required DailyReadingRecord record,
    required bool isDark,
  }) {
    final isToday = AppState.dayKey(date) == AppState.dayKey(DateTime.now());
    final dateLabel = isToday
        ? 'Today (${_formatDate(date)})'
        : _formatDate(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFFAF9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF5E35B1).withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF5E35B1)),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      AppState.formatDuration(record.seconds),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_stories_rounded, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Books Read on this Date:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    if (record.bookTitles.isNotEmpty)
                      ...record.bookTitles.map(
                        (title) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 15, color: Color(0xFF5E35B1)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        record.seconds > 0
                            ? 'Reading session in progress'
                            : 'No reading recorded for this date. Open a book to track reading time!',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}

class _StreakSummary extends StatelessWidget {
  const _StreakSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalReadingSeconds,
  });

  final int currentStreak;
  final int bestStreak;
  final int totalReadingSeconds;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF261D12) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF452B0F) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 38,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currentStreak Day Streak',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best streak: $bestStreak days  •  Total time: ${AppState.formatDuration(totalReadingSeconds)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
