import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/download_service.dart';

class ReaderScreen extends StatefulWidget {
  final String chapterSlug;
  final String chapterNumber;

  const ReaderScreen({
    super.key,
    required this.chapterSlug,
    required this.chapterNumber,
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
  double _downloadProgress = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChapter();
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
    }
  }

  Future<void> _downloadChapter() async {
    if (_chapter == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    await DownloadService.downloadChapter(
      widget.chapterSlug,
      _chapter!.imageUrls,
      (current, total) {
        setState(() {
          _downloadProgress = current / total;
        });
      },
    );

    setState(() {
      _isDownloading = false;
      _isOffline = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter yuklab olindi!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapterNumber}'),
        actions: [
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
          : Stack(
              children: [
                ListView.builder(
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
                if (_isDownloading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            value: _downloadProgress,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${(_downloadProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
    _scrollController.dispose();
    super.dispose();
  }
}
