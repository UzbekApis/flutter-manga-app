import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import 'manga_detail_screen.dart';
import 'downloads_screen.dart';
import 'favorites_screen.dart';
import 'reading_list_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Yangi chapterlarni tekshirish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForNewChapters();
      _loadRecommendations();
    });
  }

  Future<void> _loadRecommendations() async {
    final provider = context.read<MangaProvider>();
    await Future.wait([
      provider.loadRecommendations(),
      provider.loadPopularWeekly(),
      provider.loadPopularMonthly(),
    ]);
  }

  Future<void> _checkForNewChapters() async {
    final provider = context.read<MangaProvider>();
    await provider.checkForNewChapters();
    
    if (provider.newChaptersNotifications.isNotEmpty && mounted) {
      _showNewChaptersDialog();
    }
  }

  void _showNewChaptersDialog() {
    final provider = context.read<MangaProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Yangi chapterlar!'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: provider.newChaptersNotifications.length,
            itemBuilder: (context, index) {
              final notification = provider.newChaptersNotifications[index];
              return ListTile(
                leading: const Icon(Icons.new_releases, color: Colors.orange),
                title: Text(notification['mangaName'] as String),
                subtitle: Text(
                  '+${notification['newChapters']} ta yangi chapter',
                  style: const TextStyle(color: Colors.orange),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearNewChaptersNotifications();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Sevimlilar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'O\'qiyotganlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReadingListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Yuklab olinganlar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Sozlamalar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Manga qidirish...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<MangaProvider>().searchManga(value);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<MangaProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              provider.searchManga(_searchController.text);
                            }
                          },
                          child: const Text('Qayta urinish'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.searchResults.isEmpty) {
                  return _buildRecommendationsView(provider);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final manga = provider.searchResults[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MangaDetailScreen(
                              mangaSlug: manga.slug,
                              mangaId: manga.id,
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
                              child: manga.coverUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: manga.coverUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image, size: 64),
                                    )
                                  : const Icon(Icons.image, size: 64),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.black54,
                              child: Text(
                                manga.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsView(MangaProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spotlight Rekomendatsiyalar
          if (provider.recommendations.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text(
                    'Tavsiya Etilamiz',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.recommendations.length,
                itemBuilder: (context, index) {
                  final manga = provider.recommendations[index];
                  return _buildMangaCard(manga, width: 160);
                },
              ),
            ),
          ],

          // Haftalik Mashhurlar
          if (provider.popularWeekly.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Haftalik Mashhurlar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.popularWeekly.length,
                itemBuilder: (context, index) {
                  final manga = provider.popularWeekly[index];
                  return _buildMangaCard(manga, width: 160);
                },
              ),
            ),
          ],

          // Oylik Mashhurlar
          if (provider.popularMonthly.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.whatshot, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    'Oylik Mashhurlar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.popularMonthly.length,
                itemBuilder: (context, index) {
                  final manga = provider.popularMonthly[index];
                  return _buildMangaCard(manga, width: 160);
                },
              ),
            ),
          ],

          // Tag bo'yicha qidirish tugmasi
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TagFilterScreen()),
                );
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Tag bo\'yicha qidirish'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.purple.shade700,
              ),
            ),
          ),

          if (provider.recommendations.isEmpty &&
              provider.popularWeekly.isEmpty &&
              provider.popularMonthly.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Manga qidiring yoki rekomendatsiyalarni kuting'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMangaCard(Manga manga, {double width = 140}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MangaDetailScreen(
              mangaSlug: manga.slug,
              mangaId: manga.id,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                child: manga.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: manga.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, size: 64),
                      )
                    : const Icon(Icons.image, size: 64),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  manga.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tag Filter Screen
class TagFilterScreen extends StatefulWidget {
  const TagFilterScreen({super.key});

  @override
  State<TagFilterScreen> createState() => _TagFilterScreenState();
}

class _TagFilterScreenState extends State<TagFilterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MangaProvider>().loadAllTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag bo\'yicha qidirish'),
        backgroundColor: Colors.purple.shade900,
        actions: [
          Consumer<MangaProvider>(
            builder: (context, provider, child) {
              if (provider.selectedTags.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    provider.clearTags();
                  },
                  child: const Text(
                    'Tozalash',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          if (provider.allTags.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Tanlangan taglar
              if (provider.selectedTags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.purple.shade900.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanlangan taglar:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.selectedTags.map((tag) {
                          final tagData = provider.allTags.firstWhere(
                            (t) => t['slug'] == tag,
                            orElse: () => {'slug': tag, 'titles': []},
                          );
                          final titles = tagData['titles'] as List?;
                          final name = titles?.firstWhere(
                            (t) => t['lang'] == 'EN',
                            orElse: () => {'content': tag},
                          )['content'] ?? tag;

                          return Chip(
                            label: Text(name),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => provider.removeTag(tag),
                            backgroundColor: Colors.purple.shade700,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                await provider.fetchByTags();
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TagResultsScreen(),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.search),
                        label: Text('Qidirish (${provider.selectedTags.length} ta tag)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Taglar ro'yxati
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.allTags.length,
                  itemBuilder: (context, index) {
                    final tag = provider.allTags[index];
                    final slug = tag['slug'] as String;
                    final titles = tag['titles'] as List;
                    final enTitle = titles.firstWhere(
                      (t) => t['lang'] == 'EN',
                      orElse: () => {'content': slug},
                    );
                    final name = enTitle['content'] as String;
                    final isSelected = provider.selectedTags.contains(slug);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(slug, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.purple)
                            : const Icon(Icons.add_circle_outline),
                        onTap: () {
                          if (isSelected) {
                            provider.removeTag(slug);
                          } else {
                            provider.addTag(slug);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Tag Results Screen
class TagResultsScreen extends StatelessWidget {
  const TagResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Natijalar'),
        backgroundColor: Colors.purple.shade900,
      ),
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tagFilteredMangas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Hech narsa topilmadi'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: provider.tagFilteredMangas.length,
            itemBuilder: (context, index) {
              final manga = provider.tagFilteredMangas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MangaDetailScreen(
                        mangaSlug: manga.slug,
                        mangaId: manga.id,
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
                        child: manga.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: manga.coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image, size: 64),
                              )
                            : const Icon(Icons.image, size: 64),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.black54,
                        child: Text(
                          manga.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
