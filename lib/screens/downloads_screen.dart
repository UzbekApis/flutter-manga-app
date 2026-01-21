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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.downloads.keys.length,
            itemBuilder: (context, index) {
              final mangaId = provider.downloads.keys.elementAt(index);
              final chapters = provider.downloads[mangaId]!;
              final firstChapter = chapters.first;
              
              return _buildMangaCard(
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
    String mangaName,
    String? coverUrl,
    List<Map<String, dynamic>> chapters,
    MangaProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: coverUrl,
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey.shade800,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.broken_image),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 90,
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
                        mangaName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${chapters.length} ta chapter yuklangan',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.offline_pin, color: Colors.green, size: 20),
                title: Text(
                  'Chapter ${chapter['chapterNumber']}',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: chapter['chapterName'] != null
                    ? Text(
                        chapter['chapterName'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${chapter['totalPages']} sahifa',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () async {
                        await provider.deleteChapter(chapter['chapterSlug'] as String);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chapter o\'chirildi')),
                          );
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
              );
            },
          ),
        ],
      ),
    );
  }
}
