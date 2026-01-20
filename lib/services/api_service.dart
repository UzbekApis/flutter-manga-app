import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/chapter.dart';

class ApiService {
  static const String baseUrl = 'https://api.senkuro.me/graphql';
  
  static final Map<String, String> headers = {
    'accept': 'application/graphql-response+json',
    'content-type': 'application/json',
    'origin': 'https://senkuro.me',
    'referer': 'https://senkuro.me/',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  };

  // Manga qidirish
  static Future<List<Manga>> searchManga(String query) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': 'e64937b4fc9c921c2141f2995473161bed921c75855c5de934752392175936bc',
          'version': 1
        }
      },
      'operationName': 'search',
      'variables': {'query': query, 'type': 'MANGA'}
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final edges = data['data']['search']['edges'] as List;
        return edges.map((e) => Manga.fromJson(e['node'])).toList();
      }
    } catch (e) {
      print('Search error: $e');
    }
    return [];
  }

  // Manga ma'lumotlari
  static Future<MangaDetail?> getMangaDetail(String slug) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': '6d8b28abb9a9ee3199f6553d8f0a61c005da8f5c56a88ebcf3778eff28d45bd5',
          'version': 1
        }
      },
      'operationName': 'fetchManga',
      'variables': {'slug': slug}
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MangaDetail.fromJson(data['data']['manga']);
      }
    } catch (e) {
      print('Detail error: $e');
    }
    return null;
  }

  // Chapterlar ro'yxati
  static Future<List<ChapterItem>> getChapters(String branchId) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': '8c854e121f05aa93b0c37889e732410df9ea207b4186c965c845a8d970bdcc12',
          'version': 1
        }
      },
      'operationName': 'fetchMangaChapters',
      'variables': {
        'branchId': branchId,
        'after': null,
        'number': null,
        'orderBy': {'direction': 'DESC', 'field': 'NUMBER'}
      }
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final edges = data['data']['mangaChapters']['edges'] as List;
        return edges.map((e) => ChapterItem.fromJson(e['node'])).toList();
      }
    } catch (e) {
      print('Chapters error: $e');
    }
    return [];
  }

  // Chapter rasmlar
  static Future<ChapterDetail?> getChapterImages(String slug) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': '8e166106650d3659d21e7aadc15e7e59e5def36f1793a9b15287c73a1e27aa50',
          'version': 1
        }
      },
      'operationName': 'fetchMangaChapter',
      'variables': {'slug': slug, 'cdnQuality': 'auto'}
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChapterDetail.fromJson(data['data']['mangaChapter']);
      }
    } catch (e) {
      print('Chapter images error: $e');
    }
    return null;
  }
}
