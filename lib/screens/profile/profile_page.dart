import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../../widgets/profile_option.dart';
import '../../widgets/profile_stat.dart';
import '../achievement_page.dart';
import '../auth/auth_screen.dart';
import '../streak_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProfilePage({super.key, this.onNavigateTab});

  void _showEditGoal(BuildContext context, AppState state) {
    int currentGoal = state.annualReadingGoal;
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annual Reading Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How many books do you aim to complete this year?'),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Books Goal',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                state.setAnnualGoal(val);
              }
              Navigator.pop(context);
            },
            child: const Text('Save Goal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final goalProgress = state.annualReadingGoal > 0
        ? (state.booksRead / state.annualReadingGoal).clamp(0.0, 1.0)
        : 0.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Text(
                state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'R',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              state.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              state.userEmail.isNotEmpty
                  ? state.userEmail
                  : (state.isAuthenticated ? 'Signed In' : 'Guest Reader'),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),

            if (!state.isAuthenticated)
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                ),
                icon: const Icon(Icons.login),
                label: const Text('Sign In / Create Account'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            const SizedBox(height: 24),

            // Real Statistics Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStat(
                    number: '${state.booksRead}',
                    label: 'Books Read',
                  ),
                  ProfileStat(
                    number: '${state.currentlyReading.length}',
                    label: 'Reading',
                  ),
                  ProfileStat(
                    number: '${state.libraryBooks.length}',
                    label: 'In Library',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Annual Reading Goal Card
            InkWell(
              onTap: () => _showEditGoal(context, state),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Annual Reading Goal',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.edit_outlined, size: 18, color: Colors.deepPurple.shade600),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${state.annualReadingGoal} books this year'),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: goalProgress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.deepPurple,
                      backgroundColor: Colors.deepPurple.shade100,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.booksRead} of ${state.annualReadingGoal} books complete (${(goalProgress * 100).toInt()}%)',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Options List
            ProfileOption(
              icon: Icons.local_fire_department,
              title: 'Reading Streak (${state.currentStreak} days)',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StreakPage()),
              ),
            ),
            ProfileOption(
              icon: Icons.emoji_events_outlined,
              title: 'Achievements',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementPage()),
              ),
            ),
            ProfileOption(
              icon: Icons.bookmark_outline,
              title: 'Saved Books',
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(1); // Go to Library tab
                }
              },
            ),
            ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
            if (state.isAuthenticated)
              ProfileOption(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: () async {
                  await state.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out successfully.')),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
