import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/course_item.dart';
import '../../services/pucem_api.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseItem item;

  const CourseDetailScreen({super.key, required this.item});

  // =========================
  // ✅ DESCARGAR Y ABRIR PDF LOCAL
  // =========================
  Future<void> _downloadAndOpenPdf(
    BuildContext context,
    String fileName,
  ) async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      scaffold.showSnackBar(
        const SnackBar(content: Text('Descargando PDF...')),
      );

      final uri = PucemApi.courseFileUri(fileName);

      final res = await http
          .get(uri, headers: PucemApi.defaultHeaders(isFile: true))
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final dir = await getTemporaryDirectory();
      final baseName = p.basename(fileName);
      final safeFileName = baseName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      if (safeFileName.isEmpty || safeFileName == '.' || safeFileName == '..') {
        throw const FormatException('Nombre de archivo inválido');
      }
      final outputName = safeFileName.toLowerCase().endsWith('.pdf')
          ? safeFileName
          : '$safeFileName.pdf';
      final file = File(p.join(dir.path, outputName));

      await file.writeAsBytes(res.bodyBytes);

      final openResult = await OpenFilex.open(file.path);
      if (openResult.type != ResultType.done) {
        throw Exception(openResult.message);
      }

      if (scaffold.mounted) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('PDF abierto correctamente.')),
        );
      }
    } catch (e) {
      if (scaffold.mounted) {
        scaffold.showSnackBar(
          SnackBar(content: Text('No se pudo abrir el PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;

    final cover = item.imageBackName.isNotEmpty
        ? PucemApi.courseImageUri(item.imageBackName).toString()
        : (item.imageName.isNotEmpty
              ? PucemApi.courseImageUri(item.imageName).toString()
              : null);

    final hasPdf = item.pdfName.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Cover
          if (cover != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  cover,
                  fit: BoxFit.cover,
                  headers: PucemApi.defaultHeaders(isImage: true),
                  errorBuilder: (_, _, _) => Container(
                    color: cs.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),

          if (item.predescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.predescription,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (item.modality.isNotEmpty)
                _Chip(icon: Icons.school, label: item.modality, color: primary),
              if (item.resolution.isNotEmpty)
                _Chip(
                  icon: Icons.verified_outlined,
                  label: item.resolution,
                  color: primary,
                ),
              if (item.price > 0)
                _Chip(
                  icon: Icons.payments_outlined,
                  label: '\$${item.price.toStringAsFixed(2)}',
                  color: primary,
                ),
            ],
          ),

          // =========================
          // ✅ BOTÓN PDF PRO
          // =========================
          if (hasPdf) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _downloadAndOpenPdf(context, item.pdfName),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Abrir PDF'),
            ),
          ],

          const SizedBox(height: 18),

          if (item.descriptionHtml.trim().isNotEmpty) ...[
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _HtmlCard(html: item.descriptionHtml),
            const SizedBox(height: 18),
          ],

          if (item.studyPlanHtml.trim().isNotEmpty) ...[
            const Text(
              'Plan de estudios',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _HtmlCard(html: item.studyPlanHtml),
          ],
        ],
      ),
    );
  }
}

class _HtmlCard extends StatelessWidget {
  final String html;
  const _HtmlCard({required this.html});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Html(data: html),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
