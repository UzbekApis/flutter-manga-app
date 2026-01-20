import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final Dio _dio = Dio();

  // Chapter yuklab olish
  static Future<String?> downloadChapter(
    String chapterSlug,
    List<String> imageUrls,
    Function(int, int) onProgress,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/$chapterSlug');
      
      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      for (int i = 0; i < imageUrls.length; i++) {
        final url = imageUrls[i];
        final fileName = 'page_${i + 1}.jpg';
        final filePath = '${chapterDir.path}/$fileName';

        await _dio.download(url, filePath);
        onProgress(i + 1, imageUrls.length);
      }

      return chapterDir.path;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  // Yuklab olingan chapterlarni olish
  static Future<List<String>> getDownloadedChapters() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      
      if (!await downloadsDir.exists()) {
        return [];
      }

      final chapters = await downloadsDir.list().toList();
      return chapters
          .where((e) => e is Directory)
          .map((e) => e.path.split('/').last)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Chapter o'chirish
  static Future<void> deleteChapter(String chapterSlug) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/$chapterSlug');
      
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }
    } catch (e) {
      print('Delete error: $e');
    }
  }

  // Offline rasmlarni olish
  static Future<List<String>> getOfflineImages(String chapterSlug) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/$chapterSlug');
      
      if (!await chapterDir.exists()) {
        return [];
      }

      final files = await chapterDir.list().toList();
      final images = files
          .where((e) => e is File && e.path.endsWith('.jpg'))
          .map((e) => e.path)
          .toList();
      
      images.sort();
      return images;
    } catch (e) {
      return [];
    }
  }
}
