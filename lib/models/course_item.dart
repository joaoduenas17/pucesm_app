class CourseAccordion {
  final int id;
  final int courseId;
  final String title;
  final String descriptionHtml;
  final String icon;

  CourseAccordion({
    required this.id,
    required this.courseId,
    required this.title,
    required this.descriptionHtml,
    required this.icon,
  });

  factory CourseAccordion.fromJson(Map<String, dynamic> json) {
    return CourseAccordion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      courseId: (json['id_course'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      descriptionHtml: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }
}

class CourseItem {
  final int id;
  final String title;
  final String predescription;

  /// HTML (viene con <div>, <ul>, etc.)
  final String descriptionHtml;
  final String studyPlanHtml;

  /// Imágenes
  final String imageName; // "imagen"
  final String imageBackName; // "imagenback"

  /// Datos varios
  final String video;
  final int views;
  final int idType; // 1=Grado, 2=Posgrado
  final String typeName; // "typename"
  final String duration;
  final String modality;
  final String resolution;

  /// Archivos
  final String pdfName; // "pdf"
  final String calendarPdfName; // "calendar_pdf"
  final String mallaRepotenciadaPdfName; // "malla_repotenciada_pdf"

  /// Precio y ruta
  final double price;
  final String routeRedirection; // "route_redirection"
  final String urlSlug; // "url"

  /// Contactos / extras (HTML o texto)
  final String methodPaymentHtml;
  final String contactHtml;
  final String obtainedTitleHtml;
  final String extraDataHtml;

  /// Flags
  final bool active;

  /// Acordeones
  final List<CourseAccordion> accordions;

  /// Fechas
  final DateTime? dateCreated;
  final DateTime? dateUpdated;

  CourseItem({
    required this.id,
    required this.title,
    required this.predescription,
    required this.descriptionHtml,
    required this.studyPlanHtml,
    required this.imageName,
    required this.imageBackName,
    required this.video,
    required this.views,
    required this.idType,
    required this.typeName,
    required this.duration,
    required this.modality,
    required this.resolution,
    required this.pdfName,
    required this.calendarPdfName,
    required this.mallaRepotenciadaPdfName,
    required this.price,
    required this.routeRedirection,
    required this.urlSlug,
    required this.methodPaymentHtml,
    required this.contactHtml,
    required this.obtainedTitleHtml,
    required this.extraDataHtml,
    required this.active,
    required this.accordions,
    required this.dateCreated,
    required this.dateUpdated,
  });

  static DateTime? _parseDate(dynamic raw) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return null;

    // A veces viene con espacio: "2026-01-07 16:23:14"
    // A veces viene ISO: "2022-01-05T15:49:27.650249"
    final normalized = s.contains(' ') ? s.replaceFirst(' ', 'T') : s;
    return DateTime.tryParse(normalized);
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final accRaw = json['acordions_course'];
    final acc = (accRaw is List)
        ? accRaw
            .whereType<Map<String, dynamic>>()
            .map(CourseAccordion.fromJson)
            .toList()
        : <CourseAccordion>[];

    return CourseItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      predescription: (json['predescription'] ?? '').toString(),
      descriptionHtml: (json['description'] ?? '').toString(),
      studyPlanHtml: (json['study_plan'] ?? '').toString(),
      imageName: (json['imagen'] ?? '').toString(),
      imageBackName: (json['imagenback'] ?? '').toString(),
      video: (json['video'] ?? '').toString(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      idType: (json['id_type'] as num?)?.toInt() ?? 0,
      typeName: (json['typename'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      modality: (json['modality'] ?? '').toString(),
      resolution: (json['resolution'] ?? '').toString(),
      pdfName: (json['pdf'] ?? '').toString(),
      calendarPdfName: (json['calendar_pdf'] ?? '').toString(),
      mallaRepotenciadaPdfName: (json['malla_repotenciada_pdf'] ?? '').toString(),
      price: _asDouble(json['price']),
      routeRedirection: (json['route_redirection'] ?? '').toString(),
      urlSlug: (json['url'] ?? '').toString(),
      methodPaymentHtml: (json['method_payment'] ?? '').toString(),
      contactHtml: (json['contact'] ?? '').toString(),
      obtainedTitleHtml: (json['obtained_title'] ?? '').toString(),
      extraDataHtml: (json['extra_data'] ?? '').toString(),
      active: (json['active'] as bool?) ?? false,
      accordions: acc,
      dateCreated: _parseDate(json['date_created']),
      dateUpdated: _parseDate(json['date_updated']),
    );
  }
}
