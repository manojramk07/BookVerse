import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _plugin.initialize(settings: initSettings);

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
      _initialized = true;
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'bookverse_actions',
    String channelName = 'BookVerse Actions',
    String channelDescription = 'Notifications for user actions and reading milestones',
  }) async {
    if (!_initialized) return;
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      final details = NotificationDetails(android: androidDetails);
      await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
    } catch (e) {
      debugPrint('[NotificationService] Notification error: $e');
    }
  }

  Future<void> notifyBookAddedToLibrary(String bookTitle) async {
    await showNotification(
      id: 101,
      title: '📚 Added to Library',
      body: '"$bookTitle" has been added to your personal library.',
    );
  }

  Future<void> notifyBookRemovedFromLibrary(String bookTitle) async {
    await showNotification(
      id: 102,
      title: '🗑️ Removed from Library',
      body: '"$bookTitle" was removed from your library.',
    );
  }

  Future<void> notifyBookFavorited(String bookTitle, bool isFav) async {
    await showNotification(
      id: 103,
      title: isFav ? '❤️ Added to Favourites' : '🤍 Removed from Favourites',
      body: isFav
          ? '"$bookTitle" saved to your favourites.'
          : '"$bookTitle" removed from favourites.',
    );
  }

  Future<void> notifyReadingStarted(String bookTitle) async {
    await showNotification(
      id: 104,
      title: '📖 Reading Started',
      body: 'Now reading "$bookTitle". Enjoy your chapter!',
    );
  }

  Future<void> notifyAchievementUnlocked(String title, int points) async {
    await showNotification(
      id: 200 + title.hashCode.abs() % 1000,
      title: '🏆 Achievement Unlocked!',
      body: 'Unlocked "$title" (+$points pts)! Check your profile.',
    );
  }

  Future<void> notifyStreakUpdated(int streak) async {
    await showNotification(
      id: 105,
      title: '🔥 Reading Streak Maintained!',
      body: "You're on a $streak day reading streak! Keep going!",
    );
  }

  Future<void> notifyGoalUpdated(int goal) async {
    await showNotification(
      id: 106,
      title: '🎯 Annual Reading Goal',
      body: 'Target updated to $goal books for this year.',
    );
  }

  Future<void> notifyReadingReminder({int currentStreak = 1}) async {
    await showNotification(
      id: 999,
      title: '⏰ Time for Your Daily Reading!',
      body: 'Keep your $currentStreak-day streak alive! Take a few minutes to read today.',
      channelId: 'bookverse_reminders',
      channelName: 'Daily Reading Reminders',
      channelDescription: 'Reminders to maintain your reading streak',
    );
  }

  Future<void> notifyDataReset() async {
    await showNotification(
      id: 107,
      title: '🔄 Reading Data Reset',
      body: 'Your reading history and records have been cleared. Profile details preserved.',
    );
  }
}
