class NewsItem {
  final int id;
  final String title;
  final String predescription;
  final String descriptionHtml;
  final String imageName;
  final String urlSlug;
  final DateTime? dateCreated;

  NewsItem({
    required this.id,
    required this.title,
    required this.predescription,
    required this.descriptionHtml,
    required this.imageName,
    required this.urlSlug,
    required this.dateCreated,
  });

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final rawDate = json['date_created']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate.replaceFirst(' ', 'T'));
    }

    return NewsItem(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      predescription: (json['predescription'] ?? '').toString(),
      descriptionHtml: (json['description'] ?? '').toString(),
      imageName: (json['imagen'] ?? '').toString(),
      urlSlug: (json['url'] ?? '').toString(),
      dateCreated: parsedDate,
    );
  }

  String get dateLabel {
    final d = dateCreated;
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
