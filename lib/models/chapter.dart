class ChapterItem {
  final String id;
  final String slug;
  final String? name;
  final String number;
  final String volume;

  ChapterItem({
    required this.id,
    required this.slug,
    this.name,
    required this.number,
    required this.volume,
  });

  factory ChapterItem.fromJson(Map<String, dynamic> json) {
    return ChapterItem(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      number: json['number'],
      volume: json['volume'],
    );
  }
}

class ChapterDetail {
  final String id;
  final String slug;
  final String number;
  final List<String> imageUrls;
  final String? nextSlug;
  final String? prevSlug;

  ChapterDetail({
    required this.id,
    required this.slug,
    required this.number,
    required this.imageUrls,
    this.nextSlug,
    this.prevSlug,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    final pages = json['pages'] as List;
    final imageUrls = pages
        .map((p) => p['image']['compress']['url'] as String)
        .toList();

    return ChapterDetail(
      id: json['id'],
      slug: json['slug'],
      number: json['number'],
      imageUrls: imageUrls,
      nextSlug: json['nextSlug'],
      prevSlug: json['prevSlug'],
    );
  }
}
