import 'package:flutter/material.dart';

import '../../services/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _heading('Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(state.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _chooseTheme(context, state),
          ),
          const Divider(),
          _heading('Reading Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.save_outlined),
            title: const Text('Auto Save Reading Progress'),
            subtitle: const Text('Remember last read position and percentage'),
            value: state.autoSaveProgress,
            onChanged: state.setAutoSaveProgress,
          ),
          const Divider(),
          _heading('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Enable Device Notifications'),
            subtitle: Text(
              state.notificationsEnabled
                  ? 'Real-time action notifications and daily reminders are active'
                  : 'Notifications are currently disabled',
            ),
            value: state.notificationsEnabled,
            onChanged: state.setNotifications,
          ),
          ListTile(
            leading: const Icon(Icons.alarm_on_rounded, color: Colors.deepPurple),
            title: const Text('Send Reading Reminder Notification'),
            subtitle: const Text('Test device reminder notification across apps'),
            trailing: const Icon(Icons.send_rounded, size: 20, color: Colors.deepPurple),
            onTap: () async {
              state.setNotifications(true);
              await state.sendReadingReminderNow();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reading reminder notification sent! Check your device notification shade.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          const Divider(),
          _heading('Storage & Privacy'),
          const ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.green),
            title: Text('100% Local & Private'),
            subtitle: Text('Your reading activity, streaks, and library are stored exclusively offline on this device.'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            title: const Text(
              'Clear Reading History & Reset App Data',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Fresh app start: resets reading progress, saved books, favorites & achievements. Your profile name and details are preserved.',
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
            onTap: () => _confirmClearData(context, state),
          ),
          const Divider(),
          _heading('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About BookVerse'),
            subtitle: const Text('Version 1.0.0 (100% Offline)'),
            onTap: () => _showInfo(
              context,
              'About BookVerse',
              'BookVerse is an offline digital library designed for classic literature and comics in PDF format, featuring zero external APIs, local streak tracking, and complete privacy.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _showInfo(
              context,
              'Privacy',
              'BookVerse does not track you or sell your reading habits. All progress, reading time records, and preferences are saved locally on your device.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      );

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
        ThemeMode.system => 'System Default',
      };

  void _chooseTheme(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: state.themeMode,
          onChanged: (mode) {
            if (mode != null && mode != state.themeMode) {
              Navigator.pop(context);
              state.setThemeMode(mode);
            } else {
              Navigator.pop(context);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                value: ThemeMode.system,
                title: Text('System Default'),
              ),
              RadioListTile(
                value: ThemeMode.light,
                title: Text('Light'),
              ),
              RadioListTile(
                value: ThemeMode.dark,
                title: Text('Dark'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Reset App Data?'),
          ],
        ),
        content: const Text(
          'This will clear all your reading progress, saved books, favorites, reading streaks, and achievements for a fresh start.\n\nYour profile name, ID, and bio will NOT be erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.clearAllDataExceptProfile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('App data reset successfully. Profile details preserved!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
