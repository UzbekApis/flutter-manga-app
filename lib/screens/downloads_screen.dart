import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import 'reader_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangaProvider>().loadDownloads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yuklab olinganlar'),
        backgroundColor: Colors.green.shade900,
      ),
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          if (provider.downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_outlined, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  Text(
                    'Hech narsa yuklab olinmagan',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          // Manga ro'yxati - faqat manga kartochkalari
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.downloads.keys.length,
            itemBuilder: (context, index) {
              final mangaId = provider.downloads.keys.elementAt(index);
              final chapters = provider.downloads[mangaId]!;
              final firstChapter = chapters.first;
              
              return _buildMangaCard(
                mangaId,
                firstChapter['mangaName'] as String,
                firstChapter['mangaCoverUrl'] as String?,
                chapters,
                provider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMangaCard(
    String mangaId,
    String mangaName,
    String? coverUrl,
    List<Map<String, dynamic>> chapters,
    MangaProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        // Mangaga bosganda chapterlar ro'yxatini ko'rsatish
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DownloadedChaptersScreen(
              mangaId: mangaId,
              mangaName: mangaName,
              coverUrl: coverUrl,
              chapters: chapters,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black87,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mangaName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${chapters.length} chapter',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
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

// Yuklab olingan chapterlar ekrani
class DownloadedChaptersScreen extends StatelessWidget {
  final String mangaId;
  final String mangaName;
  final String? coverUrl;
  final List<Map<String, dynamic>> chapters;

  const DownloadedChaptersScreen({
    super.key,
    required this.mangaId,
    required this.mangaName,
    required this.coverUrl,
    required this.chapters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mangaName),
        backgroundColor: Colors.green.shade900,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.offline_pin, color: Colors.green),
              title: Text(
                'Chapter ${chapter['chapterNumber']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: chapter['chapterName'] != null
                  ? Text(
                      chapter['chapterName'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${chapter['totalPages']} sahifa',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final provider = context.read<MangaProvider>();
                      await provider.deleteChapter(chapter['chapterSlug'] as String);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chapter o\'chirildi')),
                        );
                        // Agar barcha chapterlar o'chirilgan bo'lsa, orqaga qaytish
                        await provider.loadDownloads();
                        if (provider.downloads[mangaId] == null || 
                            provider.downloads[mangaId]!.isEmpty) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(
                      chapterSlug: chapter['chapterSlug'] as String,
                      chapterNumber: chapter['chapterNumber'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
