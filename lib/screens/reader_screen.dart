import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/download_service.dart';
import '../providers/manga_provider.dart';

class ReaderScreen extends StatefulWidget {
  final String chapterSlug;
  final String chapterNumber;
  final int initialPage;
  final double? initialScrollOffset;
  final String? mangaId;
  final String? mangaSlug;
  final String? mangaName;
  final String? mangaCoverUrl;
  final int? totalChapters;

  const ReaderScreen({
    super.key,
    required this.chapterSlug,
    required this.chapterNumber,
    this.initialPage = 0,
    this.initialScrollOffset,
    this.mangaId,
    this.mangaSlug,
    this.mangaName,
    this.mangaCoverUrl,
    this.totalChapters,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  ChapterDetail? _chapter;
  List<String> _images = [];
  bool _isLoading = true;
  bool _isOffline = false;
  bool _isDownloading = false;

  final ScrollController _scrollController = ScrollController();
  
  // Scroll pozitsiyasini saqlash uchun timer
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _loadChapter();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_images.isEmpty || !_scrollController.hasClients) return;
    
    // Hozirgi scroll pozitsiyasini saqlash (debounce bilan)
    final scrollOffset = _scrollController.offset;
    
    // Sahifa raqamini aniqlash uchun har bir rasmning balandligini bilish kerak
    // Lekin biz faqat scroll pozitsiyasini saqlaymiz, sahifa raqami emas
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    // Timer bilan debounce - har 2 soniyada bir marta saqlash
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () async {
      if (widget.mangaId != null && widget.mangaSlug != null && widget.mangaName != null) {
        if (_scrollController.hasClients) {
          final scrollOffset = _scrollController.offset;
          
          // Hozirgi sahifani taxminiy hisoblash (faqat ko'rsatish uchun)
          final screenHeight = MediaQuery.of(context).size.height;
          final currentPage = (scrollOffset / screenHeight).floor();
          
          await context.read<MangaProvider>().updateReadingProgress(
            widget.mangaId!,
            widget.mangaSlug!,
            widget.mangaName!,
            widget.mangaCoverUrl,
            widget.chapterSlug,
            widget.chapterNumber,
            currentPage,
            widget.totalChapters ?? 0,
            scrollOffset: scrollOffset,
          );
          
          print('Saved: offset=$scrollOffset, page=$currentPage/${_images.length}');
        }
      }
    });
  }

  Future<void> _loadChapter() async {
    // Avval offline tekshirish
    final offlineImages = await DownloadService.getOfflineImages(widget.chapterSlug);
    
    if (offlineImages.isNotEmpty) {
      setState(() {
        _images = offlineImages;
        _isOffline = true;
        _isLoading = false;
      });
      
      print('Loaded ${offlineImages.length} offline images');
      
      // Aniq scroll pozitsiyasiga o'tish
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          if (widget.initialScrollOffset != null && widget.initialScrollOffset! > 0) {
            // Aniq pixel pozitsiyasiga o'tish
            _scrollController.jumpTo(widget.initialScrollOffset!);
            print('Jumped to exact offset: ${widget.initialScrollOffset}');
          } else if (widget.initialPage > 0 && widget.initialPage < offlineImages.length) {
            // Sahifa raqami bo'yicha o'tish
            final screenHeight = MediaQuery.of(context).size.height;
            final targetOffset = widget.initialPage * screenHeight;
            _scrollController.jumpTo(targetOffset);
            print('Jumped to page ${widget.initialPage} at offset $targetOffset');
          }
        }
      });
      return;
    }

    // Online yuklash
    final chapter = await ApiService.getChapterImages(widget.chapterSlug);
    if (chapter != null) {
      setState(() {
        _chapter = chapter;
        _images = chapter.imageUrls;
        _isLoading = false;
      });
      
      print('Loaded ${chapter.imageUrls.length} online images');
      
      // Aniq scroll pozitsiyasiga o'tish
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          if (widget.initialScrollOffset != null && widget.initialScrollOffset! > 0) {
            // Aniq pixel pozitsiyasiga o'tish
            _scrollController.jumpTo(widget.initialScrollOffset!);
            print('Jumped to exact offset: ${widget.initialScrollOffset}');
          } else if (widget.initialPage > 0 && widget.initialPage < chapter.imageUrls.length) {
            // Sahifa raqami bo'yicha o'tish
            final screenHeight = MediaQuery.of(context).size.height;
            final targetOffset = widget.initialPage * screenHeight;
            _scrollController.jumpTo(targetOffset);
            print('Jumped to page ${widget.initialPage} at offset $targetOffset');
          }
        }
      });
    }
  }

  Future<void> _downloadChapter() async {
    if (_chapter == null) return;

    // Background download - progress bar ko'rsatmaslik
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chapter yuklab olinmoqda...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Background'da yuklab olish
    if (widget.mangaId != null && widget.mangaSlug != null && widget.mangaName != null) {
      context.read<MangaProvider>().downloadChapter(
        widget.mangaId!,
        widget.mangaSlug!,
        widget.mangaName!,
        widget.mangaCoverUrl,
        widget.chapterSlug,
        widget.chapterNumber,
        null,
        _chapter!.imageUrls,
        (current, total) {
          // Progress faqat log uchun
          if (current == total) {
            if (mounted) {
              setState(() {
                _isOffline = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Chapter yuklab olindi!')),
              );
            }
          }
        },
      );
    } else {
      DownloadService.downloadChapter(
        widget.chapterSlug,
        _chapter!.imageUrls,
        (current, total) {
          if (current == total) {
            if (mounted) {
              setState(() {
                _isOffline = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Chapter yuklab olindi!')),
              );
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapterNumber}'),
        actions: [
          if (_images.isNotEmpty && _scrollController.hasClients)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  () {
                    final screenHeight = MediaQuery.of(context).size.height;
                    final currentPage = (_scrollController.offset / screenHeight).floor() + 1;
                    return '$currentPage/${_images.length}';
                  }(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (!_isOffline && !_isDownloading && _chapter != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadChapter,
            ),
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.offline_pin, color: Colors.green),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final imageUrl = _images[index];
                return _isOffline
                    ? Image.file(
                        File(imageUrl),
                        fit: BoxFit.fitWidth,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.fitWidth,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.error, size: 64),
                        ),
                      );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_chapter?.prevSlug != null)
            FloatingActionButton(
              heroTag: 'prev',
              mini: true,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(
                      chapterSlug: _chapter!.prevSlug!,
                      chapterNumber: (int.parse(widget.chapterNumber) - 1).toString(),
                      mangaId: widget.mangaId,
                      mangaSlug: widget.mangaSlug,
                      mangaName: widget.mangaName,
                      mangaCoverUrl: widget.mangaCoverUrl,
                      totalChapters: widget.totalChapters,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.arrow_back),
            ),
          const SizedBox(height: 8),
          if (_chapter?.nextSlug != null)
            FloatingActionButton(
              heroTag: 'next',
              mini: true,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(
                      chapterSlug: _chapter!.nextSlug!,
                      chapterNumber: (int.parse(widget.chapterNumber) + 1).toString(),
                      mangaId: widget.mangaId,
                      mangaSlug: widget.mangaSlug,
                      mangaName: widget.mangaName,
                      mangaCoverUrl: widget.mangaCoverUrl,
                      totalChapters: widget.totalChapters,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Oxirgi marta saqlash
    if (widget.mangaId != null && widget.mangaSlug != null && widget.mangaName != null) {
      if (_scrollController.hasClients) {
        final scrollOffset = _scrollController.offset;
        final screenHeight = MediaQuery.of(context).size.height;
        final currentPage = (scrollOffset / screenHeight).floor();
        
        context.read<MangaProvider>().updateReadingProgress(
          widget.mangaId!,
          widget.mangaSlug!,
          widget.mangaName!,
          widget.mangaCoverUrl,
          widget.chapterSlug,
          widget.chapterNumber,
          currentPage,
          widget.totalChapters ?? 0,
          scrollOffset: scrollOffset,
        );
      }
    }
    _scrollController.dispose();
    super.dispose();
  }
}
