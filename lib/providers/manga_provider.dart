import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/download_service.dart';

class MangaProvider extends ChangeNotifier {
  List<Manga> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Manga> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
