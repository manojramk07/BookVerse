import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final Color color;
  final double progress;
  final String? coverUrl;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.color,
    this.progress = 0.0,
    this.coverUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          color: isDark ? const Color(0xFF181B26) : Colors.white,
          elevation: isDark ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: coverUrl != null && coverUrl!.isNotEmpty
                          ? Image.network(
                              coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(
                                  Icons.menu_book,
                                  size: 55,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 55,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    fontSize: 13,
                  ),
                ),
                if (progress > 0) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor:
                        isDark ? const Color(0xFF232838) : Colors.grey.shade200,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
