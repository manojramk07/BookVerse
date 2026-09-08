import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String number;
  final String label;
  final IconData? icon;
  final Color? color;

  const ProfileStat({
    super.key,
    required this.number,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statColor = color ?? const Color(0xFF673AB7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: statColor.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statColor.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: statColor, size: 20),
            const SizedBox(height: 6),
          ],
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
