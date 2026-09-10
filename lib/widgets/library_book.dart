import 'package:flutter/material.dart';

class LibraryBook extends StatelessWidget {
  final String title;
  final String author;
  final double progress;
  final Color color;
  final String? coverUrl;

  const LibraryBook({
    super.key,
    required this.title,
    required this.author,
    required this.progress,
    required this.color,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: isDark ? const Color(0xFF181B26) : Colors.white,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 65,
                height: 90,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: coverUrl != null && coverUrl!.isNotEmpty
                    ? Image.network(
                        coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.menu_book,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 32,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.menu_book,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.deepPurple,
                    backgroundColor:
                        isDark ? const Color(0xFF232838) : Colors.grey.shade200,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
