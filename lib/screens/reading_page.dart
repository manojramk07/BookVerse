import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../models/book_model.dart';
import '../services/app_state.dart';
import '../services/local_book_service.dart';
import '../services/notification_service.dart';

class ReadingPage extends StatefulWidget {
  final Book book;
  final Widget Function(BuildContext context, String assetPath, PdfViewerController controller)? pdfViewerBuilder;

  const ReadingPage({
    super.key,
    required this.book,
    this.pdfViewerBuilder,
  });

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final LocalBookService _localBookService = LocalBookService();
  late final PdfViewerController _pdfViewerController;

  late final ValueNotifier<int> _currentPageNotifier;
  late final ValueNotifier<int> _totalPagesNotifier;
  late final ValueNotifier<double> _progressNotifier;
  late final ValueNotifier<bool> _isVerticalScrubbingNotifier;
  late final ValueNotifier<int> _scrubPageNotifier;

  bool _initialized = false;
  bool isLoading = true;
  String? effectiveAssetPath;
  String? errorMessage;
  bool isBookmarked = false;
  Timer? _debounceTimer;
  Timer? _sessionTimer;
  DateTime _lastTickTime = DateTime.now();
  AppState? _appState;
  double _dragStartY = 0.0;
  int _dragStartPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _currentPageNotifier = ValueNotifier<int>(1);
    _totalPagesNotifier = ValueNotifier<int>(1);
    _progressNotifier = ValueNotifier<double>(0.0);
    _isVerticalScrubbingNotifier = ValueNotifier<bool>(false);
    _scrubPageNotifier = ValueNotifier<int>(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appState = AppStateScope.of(context);
    if (!_initialized) {
      _initialized = true;
      final savedProgress = _appState?.progressFor(widget.book) ?? 0.0;
      final savedPos = _appState?.positionFor(widget.book) ?? 0.0;
      _progressNotifier.value = savedProgress;
      if (savedPos >= 1) {
        _currentPageNotifier.value = savedPos.toInt();
      }
      isBookmarked = _appState?.isBookFavorite(widget.book.id) ?? false;
      _startReadingSessionTimer();
      _loadBookContent();
    }
  }

  void _startReadingSessionTimer() {
    _lastTickTime = DateTime.now();
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTickTime).inSeconds;
      if (elapsed >= 1 && _appState != null) {
        _lastTickTime = now;
        _appState!.recordReadingTime(
          book: widget.book,
          seconds: elapsed,
        );
      }
    });
  }

  void _flushReadingSessionTime() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTickTime).inSeconds;
    if (elapsed > 0 && _appState != null) {
      _lastTickTime = now;
      _appState!.recordReadingTime(
        book: widget.book,
        seconds: elapsed,
      );
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _flushReadingSessionTime();
    _debounceTimer?.cancel();
    _saveProgressImmediate();
    _pdfViewerController.dispose();
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    _progressNotifier.dispose();
    _isVerticalScrubbingNotifier.dispose();
    _scrubPageNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadBookContent() async {
    final book = widget.book;
    final localBook = _localBookService.getBookById(book.id);
    var asset = localBook?.assetPath ?? book.assetPath ?? book.contentAssetPath;
    // Always normalize legacy .txt paths to genuine .pdf
    if (asset != null && asset.toLowerCase().endsWith('.txt')) {
      asset = asset.replaceAll(RegExp(r'\.txt$', caseSensitive: false), '.pdf');
    }

    debugPrint('[BOOKVERSE] Reader opened');
    debugPrint('[BOOKVERSE] Book title: ${book.title}');
    debugPrint('[BOOKVERSE] Content asset: ${asset ?? "none"}');
    debugPrint('[BOOKVERSE] Loading asset...');

    // 1. Check local assets (offline-first)
    if (asset != null && asset.isNotEmpty) {
      try {
        final ByteData data = await rootBundle.load(asset);
        debugPrint('[BOOKVERSE] Asset loaded successfully');
        debugPrint('[BOOKVERSE] Content length: ${data.lengthInBytes}');
        if (!mounted) return;
        NotificationService.instance.notifyReadingStarted(book.title);
        setState(() {
          effectiveAssetPath = asset;
          isLoading = false;
          errorMessage = null;
        });
        return;
      } catch (e) {
        debugPrint('[BOOKVERSE] Asset loading FAILED');
        debugPrint('[BOOKVERSE] Asset path: $asset');
        debugPrint('[BOOKVERSE] ERROR: $e');
      }
    } else {
      debugPrint('[BOOKVERSE] Asset loading FAILED');
      debugPrint('[BOOKVERSE] Asset path: none');
      debugPrint('[BOOKVERSE] ERROR: No asset path found for ${book.title}');
    }

    // 2. If local loading fails, show user-facing error (no mention of internet connection)
    if (!mounted) return;
    setState(() {
      isLoading = false;
      errorMessage = 'Unable to open this book.\nCould not load the file for "${book.title}" from local storage.';
    });
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    final total = details.document.pages.count;
    _totalPagesNotifier.value = total;
    final savedPos = _appState?.positionFor(widget.book) ?? 0.0;
    if (savedPos >= 1 && savedPos <= total) {
      _currentPageNotifier.value = savedPos.toInt();
      _progressNotifier.value = (savedPos / total).clamp(0.0, 1.0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && savedPos > 1) {
          _pdfViewerController.jumpToPage(savedPos.toInt());
        }
      });
    }
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    final total = _pdfViewerController.pageCount;
    final current = details.newPageNumber;
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    // Update value notifiers without rebuilding SfPdfViewer
    if (_currentPageNotifier.value != current) {
      _currentPageNotifier.value = current;
    }
    if (_totalPagesNotifier.value != total) {
      _totalPagesNotifier.value = total;
    }
    if ((_progressNotifier.value - progress).abs() > 0.001) {
      _progressNotifier.value = progress;
    }

    // Debounce progress writes to storage/Firestore every 1.5 seconds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveProgressImmediate();
    });
  }

  void _saveProgressImmediate() {
    final total = _pdfViewerController.pageCount;
    if (total <= 0) return;
    final current = _pdfViewerController.pageNumber;
    final progress = (current / total).clamp(0.0, 1.0);

    // Only record progress if valid page
    if (current > 0 && _appState != null) {
      _appState!.recordReadingProgress(
        book: widget.book,
        progress: progress,
        position: current.toDouble(),
        isCompleted: current >= total,
      );
    }
  }

  void _showJumpToPageDialog(BuildContext context, int current, int total) {
    if (total <= 1) return;
    final textController = TextEditingController(text: current.toString());
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.swap_vert_rounded, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Jump to Page', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a page number between 1 and $total:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '1 - $total',
                prefixIcon: const Icon(Icons.bookmark_outline, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: () {
              final val = int.tryParse(textController.text.trim());
              if (val != null && val >= 1 && val <= total) {
                Navigator.pop(ctx);
                _currentPageNotifier.value = val;
                _pdfViewerController.jumpToPage(val);
                _saveProgressImmediate();
              }
            },
            child: const Text('Jump'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSmartScrubber(double availableHeight) {
    const topMargin = 16.0;
    const bottomMargin = 16.0;
    const thumbHeight = 44.0;
    final usableHeight = availableHeight - topMargin - bottomMargin - thumbHeight;

    if (usableHeight <= 0) return const SizedBox.shrink();

    return ValueListenableBuilder<int>(
      valueListenable: _totalPagesNotifier,
      builder: (context, total, _) {
        if (total <= 1) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: _currentPageNotifier,
          builder: (context, current, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isVerticalScrubbingNotifier,
              builder: (context, isScrubbing, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _scrubPageNotifier,
                  builder: (context, scrubPage, _) {
                    final displayPage = isScrubbing ? scrubPage : current;
                    final fraction = ((displayPage - 1) / (total - 1)).clamp(0.0, 1.0);
                    final topOffset = topMargin + (fraction * usableHeight);

                    return SizedBox(
                      width: isScrubbing ? 140 : 36,
                      height: availableHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Track guide with tap-to-scrub
                          Positioned(
                            right: 0,
                            top: topMargin,
                            bottom: bottomMargin,
                            width: 36,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTapDown: (details) {
                                final localY = (details.localPosition.dy - (thumbHeight / 2)).clamp(0.0, usableHeight);
                                final ratio = localY / usableHeight;
                                final targetPage = (1 + (ratio * (total - 1))).round().clamp(1, total);
                                _currentPageNotifier.value = targetPage;
                                _pdfViewerController.jumpToPage(targetPage);
                                _saveProgressImmediate();
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: Container(
                                    width: 3,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Floating Smart Badge when scrubbing
                          if (isScrubbing)
                            Positioned(
                              right: 36,
                              top: (topOffset - 2).clamp(topMargin, availableHeight - bottomMargin - 36),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade800.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(-2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Page $displayPage / $total',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          // Draggable Pill Handle
                          Positioned(
                            right: 3,
                            top: topOffset,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onVerticalDragStart: (details) {
                                _dragStartY = details.globalPosition.dy;
                                _dragStartPage = current;
                                _isVerticalScrubbingNotifier.value = true;
                                _scrubPageNotifier.value = current;
                              },
                              onVerticalDragUpdate: (details) {
                                final dy = details.globalPosition.dy - _dragStartY;
                                final pageDelta = (dy / usableHeight) * (total - 1);
                                final targetPage = (_dragStartPage + pageDelta).round().clamp(1, total);
                                _scrubPageNotifier.value = targetPage;
                              },
                              onVerticalDragEnd: (details) {
                                final target = _scrubPageNotifier.value;
                                _isVerticalScrubbingNotifier.value = false;
                                _currentPageNotifier.value = target;
                                _pdfViewerController.jumpToPage(target);
                                _saveProgressImmediate();
                              },
                              child: Container(
                                width: 24,
                                height: thumbHeight,
                                decoration: BoxDecoration(
                                  color: isScrubbing
                                      ? Colors.deepPurple
                                      : Colors.deepPurple.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isScrubbing ? 0.35 : 0.2),
                                      blurRadius: isScrubbing ? 6 : 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.unfold_more,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final appState = _appState ?? AppStateScope.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              appState.toggleFavorite(book);
              setState(() {
                isBookmarked = appState.isBookFavorite(book.id);
              });
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.deepPurple : null,
            ),
            tooltip: 'Bookmark book',
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading book content...',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Unable to open this book.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Back'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  _loadBookContent();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Header with progress and page info (isolated with ValueListenableBuilder)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ValueListenableBuilder<double>(
                          valueListenable: _progressNotifier,
                          builder: (context, progress, _) {
                            return ValueListenableBuilder<int>(
                              valueListenable: _currentPageNotifier,
                              builder: (context, current, _) {
                                return ValueListenableBuilder<int>(
                                  valueListenable: _totalPagesNotifier,
                                  builder: (context, total, _) {
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.picture_as_pdf_rounded, color: Colors.deepPurple, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  book.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.deepPurple,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                total > 1
                                                    ? 'Page $current of $total  (${(progress * 100).toInt()}%)'
                                                    : '${(progress * 100).toInt()}%',
                                                style: const TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(6),
                                          backgroundColor: Colors.grey.shade200,
                                          color: Colors.deepPurple,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // PDF Viewer + Right-edge Smart Vertical Scrubber
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                widget.pdfViewerBuilder != null
                                    ? widget.pdfViewerBuilder!(context, effectiveAssetPath!, _pdfViewerController)
                                    : SfPdfViewer.asset(
                                        effectiveAssetPath!,
                                        controller: _pdfViewerController,
                                        canShowScrollHead: false,
                                        canShowScrollStatus: false,
                                        canShowPaginationDialog: false,
                                        enableDoubleTapZooming: false,
                                        enableTextSelection: false,
                                        pageSpacing: 4,
                                        pageLayoutMode: PdfPageLayoutMode.continuous,
                                        scrollDirection: PdfScrollDirection.vertical,
                                        interactionMode: PdfInteractionMode.pan,
                                        onDocumentLoaded: _onDocumentLoaded,
                                        onPageChanged: _onPageChanged,
                                        onDocumentLoadFailed: (details) {
                                          debugPrint('[BOOKVERSE] Document load failed: ${details.description}');
                                          if (mounted) {
                                            setState(() {
                                              errorMessage = 'Unable to open this book.\n${details.description}';
                                            });
                                          }
                                        },
                                      ),
                                // Right-edge Smart Scrubber
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  child: _buildVerticalSmartScrubber(constraints.maxHeight),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Bottom Smart Sliding Bar (isolated with ValueListenableBuilder)
                      ValueListenableBuilder<int>(
                        valueListenable: _currentPageNotifier,
                        builder: (context, current, _) {
                          return ValueListenableBuilder<int>(
                            valueListenable: _totalPagesNotifier,
                            builder: (context, total, _) {
                              final maxPage = total > 1 ? total.toDouble() : 1.0;
                              final sliderValue = current.toDouble().clamp(1.0, maxPage);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     // Sliding Bar Row
                                     Row(
                                       children: [
                                         IconButton(
                                           tooltip: 'Previous Page',
                                           icon: const Icon(Icons.chevron_left, size: 28),
                                           padding: EdgeInsets.zero,
                                           constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                           onPressed: current > 1
                                               ? () {
                                                   _pdfViewerController.previousPage();
                                                   _saveProgressImmediate();
                                                 }
                                               : null,
                                         ),
                                         Expanded(
                                           child: SliderTheme(
                                             data: SliderTheme.of(context).copyWith(
                                               trackHeight: 4,
                                               thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 3),
                                               overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                                               activeTrackColor: Colors.deepPurple,
                                               inactiveTrackColor: Colors.deepPurple.shade100.withValues(alpha: 0.4),
                                               thumbColor: Colors.deepPurple,
                                               overlayColor: Colors.deepPurple.withValues(alpha: 0.15),
                                             ),
                                             child: Slider(
                                               value: sliderValue,
                                               min: 1.0,
                                               max: maxPage,
                                               divisions: total > 1 ? total - 1 : 1,
                                               label: 'Page $current of $total',
                                               onChanged: (val) {
                                                 final target = val.round();
                                                 _currentPageNotifier.value = target;
                                                 _progressNotifier.value = total > 0 ? (target / total).clamp(0.0, 1.0) : 0.0;
                                               },
                                               onChangeEnd: (val) {
                                                 final target = val.round();
                                                 _pdfViewerController.jumpToPage(target);
                                                 _saveProgressImmediate();
                                               },
                                             ),
                                           ),
                                         ),
                                         IconButton(
                                           tooltip: 'Next Page',
                                           icon: const Icon(Icons.chevron_right, size: 28),
                                           padding: EdgeInsets.zero,
                                           constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                           onPressed: current < total
                                               ? () {
                                                   _pdfViewerController.nextPage();
                                                   _saveProgressImmediate();
                                                 }
                                               : null,
                                         ),
                                       ],
                                     ),
                                      // Smart Jump Pill & Page Counter
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _showJumpToPageDialog(context, current, total),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.deepPurple.shade900.withValues(alpha: 0.45)
                                                : Colors.deepPurple.shade50,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.deepPurple.withValues(alpha: 0.25),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.touch_app_outlined, size: 14, color: Colors.deepPurple),
                                              const SizedBox(width: 6),
                                              Text(
                                                total > 1 ? 'Page $current of $total  •  Tap to Jump' : 'Page $current',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.deepPurple,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                   ],
                                 ),
                               );
                            },
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}


