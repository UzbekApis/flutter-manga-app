import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../providers/manga_provider.dart';
import 'reader_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final String mangaSlug;
  final String mangaId;

  const MangaDetailScreen({
    super.key,
    required this.mangaSlug,
    required this.mangaId,
  });

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  MangaDetail? _detail;
  List<ChapterItem> _chapters = [];
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  Map<String, dynamic>? _readingProgress;
  Set<String> _downloadedChapters = {};
  Set<int> _selectedChapters = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final provider = context.read<MangaProvider>();
      
      // Sevimlilarni tekshirish
      _isFavorite = await provider.isFavorite(widget.mangaId);
      
      // O'qish progressini olish
      _readingProgress = await provider.getReadingProgress(widget.mangaId);
      
      // Manga ma'lumotlarini olish
      final detail = await ApiService.getMangaDetail(widget.mangaSlug);
      if (detail != null && detail.branches.isNotEmpty) {
        final chapters = await ApiService.getChapters(detail.branches[0].id);
        
        // Yuklab olingan chapterlarni tekshirish
        for (var chapter in chapters) {
          final isDownloaded = await provider.isChapterDownloaded(chapter.slug);
          if (isDownloaded) {
            _downloadedChapters.add(chapter.slug);
          }
        }
        
        // Kuzatuvga qo'shish
        await provider.trackManga(
          widget.mangaId,
          widget.mangaSlug,
          detail.name,
          detail.branches[0].chapters,
        );
        
        if (mounted) {
          setState(() {
            _detail = detail;
            _chapters = chapters;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Ma\'lumot topilmadi';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final provider = context.read<MangaProvider>();
    await provider.toggleFavorite(
      widget.mangaId,
      widget.mangaSlug,
      _detail?.name ?? '',
      _detail?.coverUrl,
    );
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Sevimlilarga qo\'shildi' : 'Sevimlilardan o\'chirildi'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _downloadChapter(ChapterItem chapter) async {
    final chapterDetail = await ApiService.getChapterImages(chapter.slug);
    if (chapterDetail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xatolik yuz berdi')),
        );
      }
      return;
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Yuklab olinmoqda...'),
        content: StatefulBuilder(
          builder: (context, setState) {
            int current = 0;
            int total = chapterDetail.imageUrls.length;
            
            context.read<MangaProvider>().downloadChapter(
              widget.mangaId,
              widget.mangaSlug,
              _detail?.name ?? '',
              _detail?.coverUrl,
              chapter.slug,
              chapter.number,
              chapter.name,
              chapterDetail.imageUrls,
              (curr, tot) {
                setState(() {
                  current = curr;
                  total = tot;
                });
              },
            ).then((_) {
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _downloadedChapters.add(chapter.slug);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yuklab olindi!')),
                );
              }
            });
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: total > 0 ? current / total : 0),
                const SizedBox(height: 16),
                Text('$current / $total sahifa'),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadMultipleChapters() async {
    if (_selectedChapters.isEmpty) return;
    
    final selectedChaptersList = _selectedChapters
        .map((index) => _chapters[index])
        .toList();
    
    setState(() {
      _isSelectionMode = false;
      _selectedChapters.clear();
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Yuklab olinmoqda...'),
        content: StatefulBuilder(
          builder: (context, setState) {
            int currentChapter = 0;
            int totalChapters = selectedChaptersList.length;
            int currentPage = 0;
            int totalPages = 0;
            
            _downloadChaptersSequentially(
              selectedChaptersList,
              (chapterIndex, pageIndex, pagesTot) {
                setState(() {
                  currentChapter = chapterIndex + 1;
                  currentPage = pageIndex;
                  totalPages = pagesTot;
                });
              },
            ).then((_) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$totalChapters ta chapter yuklab olindi!')),
                );
                _loadData();
              }
            });
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Chapter $currentChapter / $totalChapters'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalPages > 0 ? currentPage / totalPages : 0,
                ),
                const SizedBox(height: 8),
                Text('$currentPage / $totalPages sahifa'),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadChaptersSequentially(
    List<ChapterItem> chapters,
    Function(int, int, int) onProgress,
  ) async {
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      
      // Dublikat tekshiruvi - agar allaqachon yuklab olingan bo'lsa, o'tkazib yuborish
      final isAlreadyDownloaded = await context.read<MangaProvider>().isChapterDownloaded(chapter.slug);
      if (isAlreadyDownloaded) {
        print('Chapter ${chapter.number} allaqachon yuklab olingan, o\'tkazib yuborildi');
        continue;
      }
      
      final chapterDetail = await ApiService.getChapterImages(chapter.slug);
      
      if (chapterDetail != null) {
        await context.read<MangaProvider>().downloadChapter(
          widget.mangaId,
          widget.mangaSlug,
          _detail?.name ?? '',
          _detail?.coverUrl,
          chapter.slug,
          chapter.number,
          chapter.name,
          chapterDetail.imageUrls,
          (curr, tot) => onProgress(i, curr, tot),
        );
        _downloadedChapters.add(chapter.slug);
      }
      
      // API rate limit uchun kichik kechikish
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _continueReading() {
    if (_readingProgress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReaderScreen(
            chapterSlug: _readingProgress!['lastChapterSlug'] as String,
            chapterNumber: _readingProgress!['lastChapterNumber'] as String,
            initialPage: _readingProgress!['lastPageIndex'] as int,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xatolik')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadData();
                },
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: _isFavorite ? Colors.red : null,
                      onPressed: _toggleFavorite,
                    ),
                    if (!_isSelectionMode)
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'download_all',
                            child: Row(
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('Hammasini yuklab olish'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'select_chapters',
                            child: Row(
                              children: [
                                Icon(Icons.checklist),
                                SizedBox(width: 8),
                                Text('Tanlash'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'download_all') {
                            // Barcha chapterlarni tanlash
                            final allIndices = List.generate(_chapters.length, (i) => i);
                            setState(() {
                              _selectedChapters = Set.from(allIndices);
                            });
                            _downloadMultipleChapters();
                          } else if (value == 'select_chapters') {
                            setState(() {
                              _isSelectionMode = true;
                            });
                          }
                        },
                      ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _detail?.name ?? '',
                      style: const TextStyle(
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                      ),
                    ),
                    background: _detail?.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: _detail!.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 64),
                          )
                        : null,
                  ),
                ),
                if (_readingProgress != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade800, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_filled, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Davom etish',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Chapter ${_readingProgress!['lastChapterNumber']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _continueReading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade800,
                            ),
                            child: const Text('O\'qish'),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Ma'lumotlar (Status, Type, Tags)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status va Type
                        Row(
                          children: [
                            if (_detail?.status != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade800,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _detail!.status!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (_detail?.type != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade800,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _detail!.type!,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        // Tags
                        if (_detail?.tags != null && _detail!.tags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Taglar',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _detail!.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade800.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.purple.shade700),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_detail?.description != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tavsif',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _detail!.description!,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chapterlar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (_isSelectionMode)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isSelectionMode = false;
                                    _selectedChapters.clear();
                                  });
                                },
                                child: const Text('Bekor qilish'),
                              ),
                              ElevatedButton(
                                onPressed: _selectedChapters.isEmpty
                                    ? null
                                    : _downloadMultipleChapters,
                                child: Text('Yuklab olish (${_selectedChapters.length})'),
                              ),
                            ],
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_chapters.length}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = _chapters[index];
                      final isDownloaded = _downloadedChapters.contains(chapter.slug);
                      final isSelected = _selectedChapters.contains(index);
                      
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: _isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedChapters.add(index);
                                    } else {
                                      _selectedChapters.remove(index);
                                    }
                                  });
                                },
                              )
                            : CircleAvatar(
                                backgroundColor: isDownloaded
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blueAccent.withOpacity(0.2),
                                child: isDownloaded
                                    ? const Icon(Icons.offline_pin, color: Colors.green)
                                    : Text(
                                        chapter.number,
                                        style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                        title: Text(
                          'Chapter ${chapter.number}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: chapter.name != null ? Text(chapter.name!) : null,
                        trailing: _isSelectionMode
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!isDownloaded)
                                    IconButton(
                                      icon: const Icon(Icons.download, size: 20),
                                      onPressed: () => _downloadChapter(chapter),
                                    ),
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                                ],
                              ),
                        onTap: _isSelectionMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedChapters.remove(index);
                                  } else {
                                    _selectedChapters.add(index);
                                  }
                                });
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReaderScreen(
                                      chapterSlug: chapter.slug,
                                      chapterNumber: chapter.number,
                                      mangaId: widget.mangaId,
                                      mangaSlug: widget.mangaSlug,
                                      mangaName: _detail?.name,
                                      mangaCoverUrl: _detail?.coverUrl,
                                      totalChapters: _chapters.length,
                                    ),
                                  ),
                                );
                              },
                      );
                    },
                    childCount: _chapters.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
              ],
            ),
    );
  }
}
