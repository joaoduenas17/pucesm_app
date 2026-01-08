class CourseItem {
  final int id;
  final String title;
  final String subtitle; // si viene descripción corta o similar
  final String descriptionHtml; // si viene html
  final String imageName; // si hay imagen
  final String urlSlug;

  CourseItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.descriptionHtml,
    required this.imageName,
    required this.urlSlug,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: (json['predescription'] ?? json['subtitle'] ?? '').toString(),
      descriptionHtml: (json['description'] ?? '').toString(),
      imageName: (json['imagen'] ?? json['image'] ?? '').toString(),
      urlSlug: (json['url'] ?? json['slug'] ?? '').toString(),
    );
  }
}
