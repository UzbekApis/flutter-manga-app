import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import 'manga_detail_screen.dart';
import 'reader_screen.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangaProvider>().loadReadingList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O\'qiyotganlar'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          if (provider.readingList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text(
                    'O\'qiyotganlar ro\'yxati bo\'sh',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.readingList.length,
            itemBuilder: (context, index) {
              final manga = provider.readingList[index];
              return _buildMangaCard(manga);
            },
          );
        },
      ),
    );
  }

  Widget _buildMangaCard(Map<String, dynamic> manga) {
    final lastChapter = manga['lastChapterNumber'] as String?;
    final lastChapterSlug = manga['lastChapterSlug'] as String?;
    final lastPageIndex = manga['lastPageIndex'] as int? ?? 0;
    final scrollOffset = (manga['scrollOffset'] as num?)?.toDouble() ?? 0.0;
    final totalChapters = manga['totalChapters'] as int? ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade900,
      child: InkWell(
        onTap: () {
          // Agar oxirgi chapter ma'lum bo'lsa, to'g'ridan-to'g'ri reader'ga o'tish
          if (lastChapterSlug != null && lastChapter != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReaderScreen(
                  chapterSlug: lastChapterSlug,
                  chapterNumber: lastChapter,
                  initialPage: lastPageIndex,
                  initialScrollOffset: scrollOffset,
                  mangaId: manga['id'] as String,
                  mangaSlug: manga['slug'] as String,
                  mangaName: manga['name'] as String,
                  mangaCoverUrl: manga['coverUrl'] as String?,
                  totalChapters: totalChapters,
                ),
              ),
            );
          } else {
            // Aks holda manga detail'ga o'tish
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailScreen(
                  mangaSlug: manga['slug'] as String,
                  mangaId: manga['id'] as String,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: manga['coverUrl'] != null
                    ? CachedNetworkImage(
                        imageUrl: manga['coverUrl'] as String,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey.shade800,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (lastChapter != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Oxirgi: Chapter $lastChapter',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (totalChapters > 0)
                      Text(
                        'Jami: $totalChapters ta chapter',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      lastChapterSlug != null 
                          ? 'Davom etish uchun bosing'
                          : 'Manga sahifasiga o\'tish',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Icon(
                lastChapterSlug != null ? Icons.play_arrow : Icons.arrow_forward_ios,
                size: lastChapterSlug != null ? 32 : 16,
                color: lastChapterSlug != null ? Colors.blue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
