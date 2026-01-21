import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Parallel yuklab olish (tezroq)
  static Future<String?> downloadChapterFast(
    String chapterSlug,
    List<String> imageUrls,
    Function(int, int) onProgress,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/$chapterSlug');
      
      // Agar allaqachon yuklab olingan bo'lsa
      if (await chapterDir.exists()) {
        final existingImages = await getOfflineImages(chapterSlug);
        if (existingImages.length == imageUrls.length) {
          print('Chapter $chapterSlug already downloaded completely');
          onProgress(imageUrls.length, imageUrls.length);
          return chapterDir.path;
        } else {
          print('Chapter $chapterSlug partially downloaded (${existingImages.length}/${imageUrls.length}), re-downloading');
        }
      }
      
      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      int completed = 0;
      final total = imageUrls.length;

      // Parallel download - 5 ta bir vaqtda
      final batchSize = 5;
      for (int i = 0; i < imageUrls.length; i += batchSize) {
        final end = (i + batchSize < imageUrls.length) ? i + batchSize : imageUrls.length;
        final batch = imageUrls.sublist(i, end);
        
        await Future.wait(
          batch.asMap().entries.map((entry) async {
            final index = i + entry.key;
            final url = entry.value;
            final fileName = 'page_${index + 1}.jpg';
            final filePath = '${chapterDir.path}/$fileName';
            
            // Agar fayl allaqachon mavjud bo'lsa, o'tkazib yuborish
            final file = File(filePath);
            if (await file.exists()) {
              final fileSize = await file.length();
              if (fileSize > 0) {
                completed++;
                onProgress(completed, total);
                return;
              }
            }
            
            try {
              await _dio.download(url, filePath);
              completed++;
              onProgress(completed, total);
            } catch (e) {
              print('Error downloading page ${index + 1}: $e');
            }
          }),
        );
      }

      return chapterDir.path;
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  // Chapter yuklab olish (eski versiya - sekinroq)
  static Future<String?> downloadChapter(
    String chapterSlug,
    List<String> imageUrls,
    Function(int, int) onProgress,
  ) async {
    // Tez versiyani ishlatish
    return downloadChapterFast(chapterSlug, imageUrls, onProgress);
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
      
      // Raqam bo'yicha to'g'ri tartibda saralash
      images.sort((a, b) {
        final aNum = int.tryParse(a.split('page_').last.split('.').first) ?? 0;
        final bNum = int.tryParse(b.split('page_').last.split('.').first) ?? 0;
        return aNum.compareTo(bNum);
      });
      
      print('Found ${images.length} offline images for $chapterSlug');
      return images;
    } catch (e) {
      print('Error getting offline images: $e');
      return [];
    }
  }
}
