import 'package:flutter/material.dart';
import '../services/download_service.dart';
import 'reader_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<String> _downloads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final downloads = await DownloadService.getDownloadedChapters();
    setState(() {
      _downloads = downloads;
      _isLoading = false;
    });
  }

  Future<void> _deleteChapter(String slug) async {
    await DownloadService.deleteChapter(slug);
    _loadDownloads();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter o\'chirildi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yuklab olinganlar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloads.isEmpty
              ? const Center(
                  child: Text('Hech narsa yuklab olinmagan'),
                )
              : ListView.builder(
                  itemCount: _downloads.length,
                  itemBuilder: (context, index) {
                    final slug = _downloads[index];
                    return ListTile(
                      leading: const Icon(Icons.offline_pin, color: Colors.green),
                      title: Text('Chapter $slug'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteChapter(slug),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(
                              chapterSlug: slug,
                              chapterNumber: slug,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
