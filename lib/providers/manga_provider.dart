import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/download_service.dart';
import '../services/database_service.dart';

class MangaProvider extends ChangeNotifier {
  List<Manga> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _readingList = [];
  Map<String, List<Map<String, dynamic>>> _downloads = {};
  List<Map<String, dynamic>> _newChaptersNotifications = [];
  
  // Yangi: Rekomendatsiyalar va taglar
  List<Manga> _recommendations = [];
  List<Manga> _popularWeekly = [];
  List<Manga> _popularMonthly = [];
  List<Map<String, dynamic>> _allTags = [];
  List<String> _selectedTags = [];
  List<String> _excludedTags = [];
  List<Manga> _tagFilteredMangas = [];

  List<Manga> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get favorites => _favorites;
  List<Map<String, dynamic>> get readingList => _readingList;
  Map<String, List<Map<String, dynamic>>> get downloads => _downloads;
  List<Map<String, dynamic>> get newChaptersNotifications => _newChaptersNotifications;
  
  List<Manga> get recommendations => _recommendations;
  List<Manga> get popularWeekly => _popularWeekly;
  List<Manga> get popularMonthly => _popularMonthly;
  List<Map<String, dynamic>> get allTags => _allTags;
  List<String> get selectedTags => _selectedTags;
  List<String> get excludedTags => _excludedTags;
  List<Manga> get tagFilteredMangas => _tagFilteredMangas;

  Future<void> searchManga(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await ApiService.searchManga(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _error = null;
    // Tag qidirish natijalarini saqlab qolish
    notifyListeners();
  }

  void clearAllSearches() {
    _searchResults = [];
    _tagFilteredMangas = [];
    _selectedTags.clear();
    _excludedTags.clear();
    _error = null;
    notifyListeners();
  }

  // SEVIMLILAR
  Future<void> loadFavorites() async {
    _favorites = await DatabaseService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id, String slug, String name, String? coverUrl) async {
    final isFav = await DatabaseService.isFavorite(id);
    if (isFav) {
      await DatabaseService.removeFromFavorites(id);
    } else {
      await DatabaseService.addToFavorites(id, slug, name, coverUrl);
    }
    await loadFavorites();
  }

  Future<bool> isFavorite(String id) async {
    return await DatabaseService.isFavorite(id);
  }

  // O'QIYOTGANLAR
  Future<void> loadReadingList() async {
    _readingList = await DatabaseService.getReadingList();
    notifyListeners();
  }

  Future<void> updateReadingProgress(
    String id,
    String slug,
    String name,
    String? coverUrl,
    String chapterSlug,
    String chapterNumber,
    int pageIndex,
    int totalChapters, {
    double? scrollOffset,
  }) async {
    await DatabaseService.updateReadingProgress(
      id, slug, name, coverUrl, chapterSlug, chapterNumber, pageIndex, totalChapters,
      scrollOffset: scrollOffset,
    );
    await loadReadingList();
  }

  Future<Map<String, dynamic>?> getReadingProgress(String mangaId) async {
    return await DatabaseService.getReadingProgress(mangaId);
  }

  // YUKLAB OLINGANLAR
  Future<void> loadDownloads() async {
    _downloads = await DatabaseService.getAllDownloadsGrouped();
    notifyListeners();
  }

  Future<void> downloadChapter(
    String mangaId,
    String mangaSlug,
    String mangaName,
    String? mangaCoverUrl,
    String chapterSlug,
    String chapterNumber,
    String? chapterName,
    List<String> imageUrls,
    Function(int, int) onProgress,
  ) async {
    final path = await DownloadService.downloadChapter(chapterSlug, imageUrls, onProgress);
    if (path != null) {
      await DatabaseService.addDownload(
        mangaId, mangaSlug, mangaName, mangaCoverUrl,
        chapterSlug, chapterNumber, chapterName, imageUrls.length,
      );
      await loadDownloads();
    }
  }

  Future<void> deleteChapter(String chapterSlug) async {
    await DownloadService.deleteChapter(chapterSlug);
    await DatabaseService.removeDownload(chapterSlug);
    await loadDownloads();
  }

  Future<bool> isChapterDownloaded(String chapterSlug) async {
    return await DatabaseService.isChapterDownloaded(chapterSlug);
  }

  // YANGI CHAPTERLAR KUZATUVI
  Future<void> checkForNewChapters() async {
    final tracked = await DatabaseService.checkForNewChapters();
    _newChaptersNotifications.clear();

    for (var manga in tracked) {
      final mangaSlug = manga['mangaSlug'] as String;
      final lastKnownCount = manga['lastKnownChapterCount'] as int;
      
      final detail = await ApiService.getMangaDetail(mangaSlug);
      if (detail != null && detail.branches.isNotEmpty) {
        final currentCount = detail.branches.first.chapters;
        
        if (currentCount > lastKnownCount) {
          _newChaptersNotifications.add({
            'mangaId': manga['mangaId'],
            'mangaName': manga['mangaName'],
            'newChapters': currentCount - lastKnownCount,
            'totalChapters': currentCount,
          });
          
          await DatabaseService.updateMangaTracking(
            manga['mangaId'] as String,
            mangaSlug,
            manga['mangaName'] as String,
            currentCount,
          );
        }
      }
    }
    
    notifyListeners();
  }

  Future<void> trackManga(String mangaId, String mangaSlug, String mangaName, int chapterCount) async {
    await DatabaseService.updateMangaTracking(mangaId, mangaSlug, mangaName, chapterCount);
  }

  void clearNewChaptersNotifications() {
    _newChaptersNotifications.clear();
    notifyListeners();
  }

  // REKOMENDATSIYALAR VA TAGLAR
  Future<void> loadRecommendations() async {
    try {
      final mainPage = await ApiService.getMainPage();
      if (mainPage['mangaSpotlight'] != null) {
        final spotlight = mainPage['mangaSpotlight'] as List;
        _recommendations = spotlight.map((m) => Manga.fromJson(m)).toList();
      }
      notifyListeners();
    } catch (e) {
      print('Recommendations error: $e');
    }
  }

  Future<void> loadPopularWeekly() async {
    _popularWeekly = await ApiService.getPopularManga(period: 'WEEK');
    notifyListeners();
  }

  Future<void> loadPopularMonthly() async {
    _popularMonthly = await ApiService.getPopularManga(period: 'MONTH');
    notifyListeners();
  }

  Future<void> loadAllTags() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _allTags = await ApiService.getMangaFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Load tags error: $e');
      _error = 'Taglarni yuklashda xatolik: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTag(String tagSlug) {
    if (!_selectedTags.contains(tagSlug)) {
      _selectedTags.add(tagSlug);
      _fetchByTags();
    }
  }

  void removeTag(String tagSlug) {
    _selectedTags.remove(tagSlug);
    if (_selectedTags.isEmpty) {
      _tagFilteredMangas.clear();
    } else {
      _fetchByTags();
    }
    notifyListeners();
  }

  void addExcludeTag(String tagSlug) {
    if (!_excludedTags.contains(tagSlug)) {
      _excludedTags.add(tagSlug);
      if (_selectedTags.isNotEmpty) {
        _fetchByTags();
      }
    }
  }

  void removeExcludeTag(String tagSlug) {
    _excludedTags.remove(tagSlug);
    if (_selectedTags.isNotEmpty) {
      _fetchByTags();
    }
    notifyListeners();
  }

  void clearTags() {
    _selectedTags.clear();
    _excludedTags.clear();
    _tagFilteredMangas.clear();
    notifyListeners();
  }

  Future<void> _fetchByTags() async {
    if (_selectedTags.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    _tagFilteredMangas = await ApiService.fetchMangasByTags(
      includeTags: _selectedTags,
      excludeTags: _excludedTags,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchByTags() async {
    await _fetchByTags();
  }
}
