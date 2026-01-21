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

  List<Manga> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get favorites => _favorites;
  List<Map<String, dynamic>> get readingList => _readingList;
  Map<String, List<Map<String, dynamic>>> get downloads => _downloads;
  List<Map<String, dynamic>> get newChaptersNotifications => _newChaptersNotifications;

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
    int totalChapters,
  ) async {
    await DatabaseService.updateReadingProgress(
      id, slug, name, coverUrl, chapterSlug, chapterNumber, pageIndex, totalChapters,
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
}
