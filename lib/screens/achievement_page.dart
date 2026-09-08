import 'package:flutter/material.dart';

import '../models/achievement_model.dart';
import '../services/app_state.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: achievementCatalog.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final achievement = achievementCatalog[index];
          final progress = state.achievementProgress(achievement);
          final unlocked = progress >= achievement.threshold;
          final progressValue = (progress / achievement.threshold)
              .clamp(0.0, 1.0)
              .toDouble();
          final unlockDate = state.achievementUnlockedOn(achievement.id);
          final accent = unlocked
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: unlocked
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: accent,
                    child: Icon(
                      unlocked ? achievement.icon : Icons.lock_outline,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              unlocked
                                  ? 'Unlocked'
                                  : '$progress/${achievement.threshold}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          unlocked && unlockDate != null
                              ? 'Unlocked ${_formatDate(unlockDate)}'
                              : 'Keep reading to unlock',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
