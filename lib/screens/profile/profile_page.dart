import 'package:flutter/material.dart';

import '../../models/achievement_model.dart';
import '../../services/app_state.dart';
import '../../widgets/profile_option.dart';
import '../../widgets/profile_stat.dart';
import '../achievement_page.dart';
import '../streak_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProfilePage({super.key, this.onNavigateTab});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _showEditProfileDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController(text: state.userName);
    final idController = TextEditingController(text: state.userId);
    final emailController = TextEditingController(text: state.userEmail);
    final bioController = TextEditingController(text: state.userBio);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Display Name
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Jane Austen',
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF673AB7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF262330) : const Color(0xFFF9F8FD),
                ),
              ),
              const SizedBox(height: 14),

              // Permanent User ID Tag (Editable)
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'User ID / Handle',
                  hintText: 'e.g. BV-4821 or your handle',
                  prefixIcon: const Icon(Icons.fingerprint, color: Color(0xFF673AB7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF262330) : const Color(0xFFF9F8FD),
                  helperText: 'Permanent identifier for your local library',
                ),
              ),
              const SizedBox(height: 14),

              // Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address (Optional)',
                  hintText: 'reader@example.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF673AB7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF262330) : const Color(0xFFF9F8FD),
                ),
              ),
              const SizedBox(height: 14),

              // Reading Bio
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Reading Motto / Bio',
                  hintText: 'e.g. Classic literature lover & midnight reader',
                  prefixIcon: const Icon(Icons.auto_stories_outlined, color: Color(0xFF673AB7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF262330) : const Color(0xFFF9F8FD),
                ),
              ),
              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newId = idController.text.trim();
                  final newEmail = emailController.text.trim();
                  final newBio = bioController.text.trim();

                  await state.updateProfile(
                    name: newName,
                    customUserId: newId.isNotEmpty ? newId : null,
                    email: newEmail,
                    bio: newBio,
                  );

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated & saved permanently!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditGoalDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.annualReadingGoal.toString());

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.flag_rounded, color: Color(0xFF673AB7)),
            SizedBox(width: 8),
            Text('Annual Reading Goal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How many books do you plan to read this year?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Target Number of Books',
                prefixIcon: const Icon(Icons.menu_book, color: Color(0xFF673AB7)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                state.setAnnualGoal(val);
              }
              Navigator.pop(ctx);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final goalProgress = state.annualReadingGoal > 0
        ? (state.booksRead / state.annualReadingGoal).clamp(0.0, 1.0)
        : 0.0;
    final unlockedAchievements = state.unlockedAchievementsCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Screen Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5E35B1),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your reading identity & library statistics',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

              // Profile Hero Card with Premium Indigo/Slate Color Scheme
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E1B2E),
                            const Color(0xFF26213D),
                          ]
                        : [
                            const Color(0xFFFAF9FF),
                            const Color(0xFFF3EFFF),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF383254)
                        : const Color(0xFFE4DCF9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF673AB7).withValues(alpha: isDark ? 0.25 : 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with Monogram & Edit Badge
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(context, state),
                      child: Stack(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF673AB7),
                                  Color(0xFF3F51B5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF673AB7).withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 3,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.userInitial,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF673AB7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User Display Name
                    Text(
                      state.userName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1F1D2B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Permanent User ID Badge (Never changes on refresh)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF673AB7).withValues(alpha: isDark ? 0.22 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF673AB7).withValues(alpha: isDark ? 0.4 : 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fingerprint,
                            size: 15,
                            color: Color(0xFF673AB7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ID: ${state.userId}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF673AB7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Total Points & Badges Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5E35B1), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${state.totalAchievementPoints} PTS  •  ${state.unlockedAchievementsCount} Badges',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (state.userEmail.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            state.userEmail,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),
                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '"${state.userBio}"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Edit Profile Button
                    FilledButton.tonalIcon(
                      onPressed: () => _showEditProfileDialog(context, state),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile Details'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7).withValues(alpha: isDark ? 0.2 : 0.12),
                        foregroundColor: const Color(0xFF673AB7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2-Color Cohesive Reading Statistics Row
              Row(
                children: [
                  Expanded(
                    child: ProfileStat(
                      number: '${state.booksRead}',
                      label: 'Finished',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF5E35B1), // Royal Indigo
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileStat(
                      number: '${state.currentlyReading.length}',
                      label: 'Reading',
                      icon: Icons.auto_stories_outlined,
                      color: const Color(0xFFD97706), // Warm Amber
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileStat(
                      number: '${state.libraryBooks.length}',
                      label: 'Library',
                      icon: Icons.bookmark_outline,
                      color: const Color(0xFF5E35B1), // Royal Indigo
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ProfileStat(
                      number: '${state.currentStreak}d',
                      label: 'Streak',
                      icon: Icons.local_fire_department_outlined,
                      color: const Color(0xFFD97706), // Warm Amber
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Annual Reading Goal Card
              InkWell(
                onTap: () => _showEditGoalDialog(context, state),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF8F6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF383254) : const Color(0xFFE4DCF9),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.flag_rounded, color: Color(0xFF673AB7), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Annual Reading Goal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF673AB7).withValues(alpha: isDark ? 0.3 : 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${(goalProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF673AB7),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF673AB7)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: goalProgress,
                          minHeight: 8,
                          color: const Color(0xFF673AB7),
                          backgroundColor: const Color(0xFF673AB7).withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.booksRead} of ${state.annualReadingGoal} books completed this year',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Quick Interactive Streak & Trophy Cards
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StreakPage()),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF261D12) : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF452B0F) : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFD97706),
                                  size: 28,
                                ),
                                Text(
                                  '${state.currentStreak} Days',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Reading Streak',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Best: ${state.bestStreak} days',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AchievementPage()),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? const Color(0xFF383254) : const Color(0xFFDDD6FE),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFF5E35B1),
                                  size: 28,
                                ),
                                Text(
                                  '$unlockedAchievements/${achievementCatalog.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF5E35B1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Achievements',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Badges unlocked',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Unlocked Achievements Showcase
              _buildAchievementsShowcase(context, state, isDark),
              const SizedBox(height: 20),

              // In-Profile Quick Theme Switcher (Lag-free)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF383254) : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Appearance',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode, size: 16),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode, size: 16),
                          ),
                        ],
                        selected: {state.themeMode},
                        onSelectionChanged: (set) {
                          if (set.isNotEmpty && set.first != state.themeMode) {
                            state.setThemeMode(set.first);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Shelves & Settings Navigation Options
              ProfileOption(
                icon: Icons.favorite_outline,
                title: 'Favorite Books (${state.favoriteBooks.length})',
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                },
              ),
              ProfileOption(
                icon: Icons.bookmark_outline,
                title: 'Saved in Library (${state.libraryBooks.length})',
                onTap: () {
                  if (widget.onNavigateTab != null) widget.onNavigateTab!(1);
                },
              ),
              ProfileOption(
                 icon: Icons.settings_outlined,
                title: 'Settings & Preferences',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildAchievementsShowcase(BuildContext context, AppState state, bool isDark) {
    final unlocked = state.unlockedAchievements;
    final totalCount = achievementCatalog.length;
    final totalPoints = state.totalAchievementPoints;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF383254) : const Color(0xFFE4DCF9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
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
              const Row(
                children: [
                  Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Achievements Showcase',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementPage()),
                ),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5E35B1),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFF5E35B1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Points & Rank banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF261D12), const Color(0xFF2B1B3D)]
                    : [const Color(0xFFFFFBEB), const Color(0xFFF5F3FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF4D3618) : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$totalPoints Points Earned',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          '${unlocked.length} of $totalCount badges unlocked',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E35B1).withValues(alpha: isDark ? 0.3 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    totalPoints >= 1000
                        ? 'Master Reader'
                        : totalPoints >= 500
                            ? 'Avid Reader'
                            : totalPoints >= 200
                                ? 'Bookworm'
                                : 'Novice Reader',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF5E35B1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Unlocked items preview
          if (unlocked.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161420) : const Color(0xFFF9F8FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 36, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  const Text(
                    'No Badges Unlocked Yet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Read books, build streaks, or add titles to your library to earn achievement badges and points!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: unlocked.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, idx) {
                  final badge = unlocked[idx];
                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161420) : const Color(0xFFF9F8FD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.3 : 0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(badge.icon, size: 24, color: const Color(0xFF5E35B1)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${badge.points}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          badge.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
