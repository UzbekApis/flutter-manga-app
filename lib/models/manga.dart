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

    String name = json['originalName'] ?? 'Unknown';
    if (json['titles'] != null) {
      final titles = json['titles'] as List;
      for (var title in titles) {
        if (title['lang'] == 'RU') {
          name = title['content'];
          break;
        }
      }
      if (name == json['originalName']) {
        for (var title in titles) {
          if (title['lang'] == 'EN') {
            name = title['content'];
            break;
          }
        }
      }
    }

    return Manga(
      id: json['id'],
      slug: json['slug'],
      name: name,
      originalName: json['originalName'],
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

  MangaDetail({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.coverUrl,
    required this.branches,
    this.chapters,
  });

  factory MangaDetail.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover'] != null && json['cover']['original'] != null) {
      coverUrl = json['cover']['original']['url'];
    }

    String name = json['originalName']?['content'] ?? 'Unknown';
    if (json['titles'] != null) {
      final titles = json['titles'] as List;
      for (var title in titles) {
        if (title['lang'] == 'RU') {
          name = title['content'];
          break;
        }
      }
    }

    String? description;
    if (json['localizations'] != null) {
      final locs = json['localizations'] as List;
      for (var loc in locs) {
        if (loc['lang'] == 'RU' && loc['description'] != null) {
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
