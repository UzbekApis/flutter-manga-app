import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/chapter.dart';
import 'proxy_service.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://api.senkuro.me/graphql';
  static const Duration timeout = Duration(seconds: 15);
  
  static final Map<String, String> headers = {
    'accept': 'application/graphql-response+json',
    'content-type': 'application/json',
    'origin': 'https://senkuro.me',
    'referer': 'https://senkuro.me/',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  };

  static Future<dynamic> _post(Map<String, dynamic> payload) async {
    try {
      // Proxy yoqilgan bo'lsa, yangi proxy tanlash
      if (ProxyService.isEnabled) {
        ProxyService.getRandomProxy();
        print('Using proxy: ${ProxyService.currentProxy}');
      }
      
      final client = ProxyService.createClient();
      
      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(timeout);
      
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errors'] != null) {
          throw ApiException((data['errors'] as List).first['message'] ?? 'Unknown API error');
        }
        return data;
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

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
      final data = await _post(payload);
      final edges = data['data']['search']['edges'] as List;
      return edges.map((e) => Manga.fromJson(e['node'])).toList();
    } catch (e) {
      print('Search error: $e');
      rethrow;
    }
  }

  // Bosh sahifa rekomendatsiyalari
  static Future<Map<String, dynamic>> getMainPage({List<String> excludeTags = const []}) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': 'c1a427930add310e7e68870182c3b17a84b3bac00a46bed07b72d0760f5fd09a',
          'version': 1
        }
      },
      'operationName': 'fetchMainPage',
      'variables': {
        'label': {'exclude': excludeTags.isEmpty ? ['female_protagonist'] : excludeTags},
        'skipAnime': true,
        'skipLabelsSpotlight': false,
        'skipManga': false,
        'skipPosts': true
      }
    };

    try {
      final data = await _post(payload);
      return data['data']['mainPage'] as Map<String, dynamic>;
    } catch (e) {
      print('Main page error: $e');
      return {};
    }
  }

  // Mashhur mangalar (haftalik/oylik)
  static Future<List<Manga>> getPopularManga({String period = 'MONTH'}) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': '896d217de6cea8cedadd67abbfeed5e17589e77708d1e38b4f6a726ae409ca67',
          'version': 1
        }
      },
      'operationName': 'fetchPopularMangaByPeriod',
      'variables': {'period': period}
    };

    try {
      final data = await _post(payload);
      // API javobida 'mangaPopularByPeriod' ishlatiladi
      final mangas = data['data']['mangaPopularByPeriod'] as List;
      return mangas.map((m) => Manga.fromJson(m)).toList();
    } catch (e) {
      print('Popular manga error: $e');
      return [];
    }
  }

  // Taglar ro'yxati
  static Future<List<Map<String, dynamic>>> getMangaFilters() async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': 'ba3a84e0b5ace4cc30f9c542ac73264d95eefcc67700f9b42214373055e36fb5',
          'version': 1
        }
      },
      'operationName': 'fetchMangaFilters'
    };

    try {
      final data = await _post(payload);
      final filters = data['data']['mangaFilters'];
      final labels = filters['labels'] as List;
      return labels.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Filters error: $e');
      return [];
    }
  }

  // Tag bo'yicha qidirish
  static Future<List<Manga>> fetchMangasByTags({
    List<String> includeTags = const [],
    List<String> excludeTags = const [],
    String orderField = 'POPULARITY_SCORE',
    String orderDirection = 'DESC',
  }) async {
    final payload = {
      'extensions': {
        'persistedQuery': {
          'sha256Hash': '2e239cbedda2c8af91bb0f86149b26889f2f800dc08ba36417cdecb91614799e',
          'version': 1
        }
      },
      'operationName': 'fetchMangas',
      'variables': {
        'after': null,
        'bookmark': {'exclude': [], 'include': []},
        'chapters': {},
        'format': {'exclude': [], 'include': []},
        'label': {
          'exclude': excludeTags,
          'include': includeTags
        },
        'orderDirection': orderDirection,
        'orderField': orderField,
        'originCountry': {'exclude': [], 'include': []},
        'rating': {'exclude': [], 'include': []},
        'releasedOn': {},
        'search': null,
        'source': {'exclude': [], 'include': []},
        'status': {'exclude': [], 'include': []},
        'translitionStatus': {'exclude': [], 'include': []},
        'type': {'exclude': [], 'include': []}
      }
    };

    try {
      final data = await _post(payload);
      final edges = data['data']['mangas']['edges'] as List;
      return edges.map((e) => Manga.fromJson(e['node'])).toList();
    } catch (e) {
      print('Fetch by tags error: $e');
      return [];
    }
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
      final data = await _post(payload);
      return MangaDetail.fromJson(data['data']['manga']);
    } catch (e) {
      print('Detail error: $e');
      return null;
    }
  }

  // Chapterlar ro'yxati (pagination bilan)
  static Future<List<ChapterItem>> getChapters(String branchId) async {
    final List<ChapterItem> allChapters = [];
    String? afterCursor;
    
    // Pagination loop
    while (true) {
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
          'after': afterCursor,
          'number': null,
          'orderBy': {'direction': 'DESC', 'field': 'NUMBER'}
        }
      };

      try {
        final data = await _post(payload);
        final mangaChapters = data['data']['mangaChapters'];
        final edges = mangaChapters['edges'] as List;
        final pageInfo = mangaChapters['pageInfo'] as Map<String, dynamic>;
        
        // Chapterlarni qo'shish
        allChapters.addAll(
          edges.map((e) => ChapterItem.fromJson(e['node'])).toList()
        );
        
        // Keyingi sahifa bormi?
        final hasNextPage = pageInfo['hasNextPage'] as bool? ?? false;
        afterCursor = pageInfo['endCursor'] as String?;
        
        if (!hasNextPage || afterCursor == null) {
          break;
        }
      } catch (e) {
        print('Chapters pagination error: $e');
        break;
      }
    }
    
    return allChapters;
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
      final data = await _post(payload);
      return ChapterDetail.fromJson(data['data']['mangaChapter']);
    } catch (e) {
      print('Chapter images error: $e');
      return null;
    }
  }
}
