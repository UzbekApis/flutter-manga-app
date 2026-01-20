import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import 'reader_screen.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  MangaDetail? _detail;
  List<ChapterItem> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final detail = await ApiService.getMangaDetail(widget.manga.slug);
    if (detail != null && detail.branches.isNotEmpty) {
      final chapters = await ApiService.getChapters(detail.branches[0].id);
      setState(() {
        _detail = detail;
        _chapters = chapters;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.manga.name,
                      style: const TextStyle(
                        shadows: [Shadow(blurRadius: 8)],
                      ),
                    ),
                    background: _detail?.coverUrl != null
                        ? Image.network(
                            _detail!.coverUrl!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                if (_detail?.description != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_detail!.description!),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Chapterlar (${_chapters.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = _chapters[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(chapter.number),
                        ),
                        title: Text('Chapter ${chapter.number}'),
                        subtitle: chapter.name != null
                            ? Text(chapter.name!)
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderScreen(
                                chapterSlug: chapter.slug,
                                chapterNumber: chapter.number,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: _chapters.length,
                  ),
                ),
              ],
            ),
    );
  }
}
