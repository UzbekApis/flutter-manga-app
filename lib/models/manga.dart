class Manga {
  final String id;
  final String slug;
  final String name;
  final String? originalName;
  final String? coverUrl;
  final String? type;
  final String? status;

  Manga({
    required this.id,
    required this.slug,
    required this.name,
    this.originalName,
    this.coverUrl,
    this.type,
    this.status,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover'] != null) {
      if (json['cover']['preview'] != null) {
        coverUrl = json['cover']['preview']['url'];
      } else if (json['cover']['original'] != null) {
        coverUrl = json['cover']['original']['url'];
      }
    }

    // Inglizcha nomni olish
    String name = 'Unknown';
    if (json['titles'] != null) {
      final titles = json['titles'] as List;
      // Avval inglizcha
      for (var title in titles) {
        if (title['lang'] == 'EN' && title['content'] != null) {
          name = title['content'].toString();
          break;
        }
      }
      // Agar inglizcha yo'q bo'lsa, originalName
      if (name == 'Unknown' && json['originalName'] != null) {
        name = json['originalName'].toString();
      }
      // Agar hali ham yo'q bo'lsa, birinchi title
      if (name == 'Unknown' && titles.isNotEmpty && titles.first['content'] != null) {
        name = titles.first['content'].toString();
      }
    } else if (json['originalName'] != null) {
      name = json['originalName'].toString();
    }

    return Manga(
      id: json['id'],
      slug: json['slug'],
      name: name,
      originalName: json['originalName']?.toString(),
      coverUrl: coverUrl,
      type: json['mangaType'] ?? json['type'],
      status: json['mangaStatus'] ?? json['status'],
    );
  }
}

class MangaDetail {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<Branch> branches;
  final int? chapters;
  final List<String> tags;
  final String? status;
  final String? type;

  MangaDetail({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.coverUrl,
    required this.branches,
    this.chapters,
    this.tags = const [],
    this.status,
    this.type,
  });

  factory MangaDetail.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover'] != null && json['cover']['original'] != null) {
      coverUrl = json['cover']['original']['url'];
    }

    // Inglizcha nomni olish
    String name = 'Unknown';
    if (json['titles'] != null) {
      final titles = json['titles'] as List;
      // Avval inglizcha
      for (var title in titles) {
        if (title['lang'] == 'EN' && title['content'] != null) {
          name = title['content'].toString();
          break;
        }
      }
      // Agar inglizcha yo'q bo'lsa, originalName
      if (name == 'Unknown' && json['originalName']?['content'] != null) {
        name = json['originalName']['content'].toString();
      }
      // Agar hali ham yo'q bo'lsa, birinchi title
      if (name == 'Unknown' && titles.isNotEmpty && titles.first['content'] != null) {
        name = titles.first['content'].toString();
      }
    } else if (json['originalName']?['content'] != null) {
      name = json['originalName']['content'].toString();
    }

    // Inglizcha tavsifni olish
    String? description;
    if (json['localizations'] != null) {
      final locs = json['localizations'] as List;
      for (var loc in locs) {
        if (loc['lang'] == 'EN' && loc['description'] != null) {
          final desc = loc['description'] as List;
          final parts = <String>[];
          for (var block in desc) {
            if (block['content'] != null) {
              for (var content in block['content']) {
                if (content['text'] != null) {
                  parts.add(content['text']);
                }
              }
            }
          }
          description = parts.join(' ');
          break;
        }
      }
    }

    // Taglarni olish
    final List<String> tags = [];
    if (json['labels'] != null) {
      final labels = json['labels'] as List;
      for (var label in labels) {
        if (label['titles'] != null) {
          final labelTitles = label['titles'] as List;
          for (var title in labelTitles) {
            if (title['lang'] == 'EN' && title['content'] != null) {
              tags.add(title['content'].toString());
              break;
            }
          }
        }
      }
    }

    final branches = (json['branches'] as List?)
            ?.map((b) => Branch.fromJson(b))
            .toList() ??
        [];

    return MangaDetail(
      id: json['id'],
      slug: json['slug'],
      name: name,
      description: description,
      coverUrl: coverUrl,
      branches: branches,
      chapters: json['chapters'],
      tags: tags,
      status: json['mangaStatus'] ?? json['status'],
      type: json['mangaType'] ?? json['type'],
    );
  }
}

class Branch {
  final String id;
  final String? lang;
  final int chapters;

  Branch({required this.id, this.lang, required this.chapters});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      lang: json['lang'],
      chapters: json['chapters'] ?? 0,
    );
  }
}
