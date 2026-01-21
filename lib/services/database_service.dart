import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manga_reader.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Sevimlilar
        await db.execute('''
          CREATE TABLE favorites (
            id TEXT PRIMARY KEY,
            slug TEXT NOT NULL,
            name TEXT NOT NULL,
            coverUrl TEXT,
            addedAt INTEGER NOT NULL
          )
        ''');

        // O'qiyotganlar
        await db.execute('''
          CREATE TABLE reading (
            id TEXT PRIMARY KEY,
            slug TEXT NOT NULL,
            name TEXT NOT NULL,
            coverUrl TEXT,
            lastChapterSlug TEXT,
            lastChapterNumber TEXT,
            lastPageIndex INTEGER DEFAULT 0,
            lastReadAt INTEGER NOT NULL,
            totalChapters INTEGER DEFAULT 0
          )
        ''');

        // Yuklab olinganlar
        await db.execute('''
          CREATE TABLE downloads (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mangaId TEXT NOT NULL,
            mangaSlug TEXT NOT NULL,
            mangaName TEXT NOT NULL,
            mangaCoverUrl TEXT,
            chapterSlug TEXT NOT NULL UNIQUE,
            chapterNumber TEXT NOT NULL,
            chapterName TEXT,
            downloadedAt INTEGER NOT NULL,
            totalPages INTEGER DEFAULT 0
          )
        ''');

        // Yangi chapterlar kuzatuvi
        await db.execute('''
          CREATE TABLE manga_tracking (
            mangaId TEXT PRIMARY KEY,
            mangaSlug TEXT NOT NULL,
            mangaName TEXT NOT NULL,
            lastKnownChapterCount INTEGER NOT NULL,
            lastCheckedAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // SEVIMLILAR
  static Future<void> addToFavorites(String id, String slug, String name, String? coverUrl) async {
    final db = await database;
    await db.insert(
      'favorites',
      {
        'id': id,
        'slug': slug,
        'name': name,
        'coverUrl': coverUrl,
        'addedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeFromFavorites(String id) async {
    final db = await database;
    await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  static Future<bool> isFavorite(String id) async {
    final db = await database;
    final result = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites', orderBy: 'addedAt DESC');
  }

  // O'QIYOTGANLAR
  static Future<void> updateReadingProgress(
    String id,
    String slug,
    String name,
    String? coverUrl,
    String chapterSlug,
    String chapterNumber,
    int pageIndex,
    int totalChapters,
  ) async {
    final db = await database;
    await db.insert(
      'reading',
      {
        'id': id,
        'slug': slug,
        'name': name,
        'coverUrl': coverUrl,
        'lastChapterSlug': chapterSlug,
        'lastChapterNumber': chapterNumber,
        'lastPageIndex': pageIndex,
        'lastReadAt': DateTime.now().millisecondsSinceEpoch,
        'totalChapters': totalChapters,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getReadingProgress(String mangaId) async {
    final db = await database;
    final result = await db.query('reading', where: 'id = ?', whereArgs: [mangaId]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<List<Map<String, dynamic>>> getReadingList() async {
    final db = await database;
    return await db.query('reading', orderBy: 'lastReadAt DESC');
  }

  // YUKLAB OLINGANLAR
  static Future<void> addDownload(
    String mangaId,
    String mangaSlug,
    String mangaName,
    String? mangaCoverUrl,
    String chapterSlug,
    String chapterNumber,
    String? chapterName,
    int totalPages,
  ) async {
    final db = await database;
    await db.insert(
      'downloads',
      {
        'mangaId': mangaId,
        'mangaSlug': mangaSlug,
        'mangaName': mangaName,
        'mangaCoverUrl': mangaCoverUrl,
        'chapterSlug': chapterSlug,
        'chapterNumber': chapterNumber,
        'chapterName': chapterName,
        'downloadedAt': DateTime.now().millisecondsSinceEpoch,
        'totalPages': totalPages,
      },
    );
  }

  static Future<void> removeDownload(String chapterSlug) async {
    final db = await database;
    await db.delete('downloads', where: 'chapterSlug = ?', whereArgs: [chapterSlug]);
  }

  static Future<List<Map<String, dynamic>>> getDownloadsByManga(String mangaId) async {
    final db = await database;
    return await db.query(
      'downloads',
      where: 'mangaId = ?',
      whereArgs: [mangaId],
      orderBy: 'chapterNumber DESC',
    );
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getAllDownloadsGrouped() async {
    final db = await database;
    final downloads = await db.query('downloads', orderBy: 'downloadedAt DESC');
    
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var download in downloads) {
      final mangaId = download['mangaId'] as String;
      if (!grouped.containsKey(mangaId)) {
        grouped[mangaId] = [];
      }
      grouped[mangaId]!.add(download);
    }
    return grouped;
  }

  static Future<bool> isChapterDownloaded(String chapterSlug) async {
    final db = await database;
    final result = await db.query('downloads', where: 'chapterSlug = ?', whereArgs: [chapterSlug]);
    return result.isNotEmpty;
  }

  // YANGI CHAPTERLAR KUZATUVI
  static Future<void> updateMangaTracking(String mangaId, String mangaSlug, String mangaName, int chapterCount) async {
    final db = await database;
    await db.insert(
      'manga_tracking',
      {
        'mangaId': mangaId,
        'mangaSlug': mangaSlug,
        'mangaName': mangaName,
        'lastKnownChapterCount': chapterCount,
        'lastCheckedAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> checkForNewChapters() async {
    final db = await database;
    final tracked = await db.query('manga_tracking');
    return tracked;
  }

  static Future<Map<String, dynamic>?> getMangaTracking(String mangaId) async {
    final db = await database;
    final result = await db.query('manga_tracking', where: 'mangaId = ?', whereArgs: [mangaId]);
    return result.isNotEmpty ? result.first : null;
  }
}
