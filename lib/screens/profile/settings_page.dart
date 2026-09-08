import 'package:flutter/material.dart';

import '../../services/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _confirmClearData(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Reading History?'),
        content: const Text(
          'This will permanently reset all your saved books, bookmarks, and reading progress stored on this device. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.clearAllReadingData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reading history cleared.')),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

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
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Reader Font Size'),
            subtitle: Text('${state.fontSize.toInt()} px'),
            trailing: SizedBox(
              width: 140,
              child: Slider(
                value: state.fontSize,
                min: 14,
                max: 24,
                divisions: 5,
                label: '${state.fontSize.toInt()} px',
                onChanged: state.setFontSize,
              ),
            ),
          ),
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
            secondary: const Icon(Icons.notifications_none),
            title: const Text('Enable Notifications'),
            subtitle: Text(
              state.notificationsEnabled
                  ? 'Daily reading reminders enabled'
                  : 'Notifications disabled',
            ),
            value: state.notificationsEnabled,
            onChanged: state.setNotifications,
          ),
          const Divider(),
          _heading('Storage & Privacy'),
          const ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.green),
            title: Text('100% Local & Private'),
            subtitle: Text('Your reading activity and library are stored exclusively on this device.'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Reading History', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Reset all reading progress, streaks, and saved books'),
            onTap: () => _confirmClearData(context, state),
          ),
          const Divider(),
          _heading('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About BookVerse'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () => _showInfo(
              context,
              'About BookVerse',
              'BookVerse is a clean, modern digital reading application powered by Google Books API for metadata discovery and Project Gutenberg for public-domain e-reading.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _showInfo(
              context,
              'Privacy',
              'BookVerse does not track you or sell your reading habits. All progress and preferences are saved locally on your device.',
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
            if (mode != null) state.setThemeMode(mode);
            Navigator.pop(context);
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
