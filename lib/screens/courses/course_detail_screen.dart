import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/course_item.dart';
import '../../services/pucem_api.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseItem item;

  const CourseDetailScreen({super.key, required this.item});

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final cover = item.imageBackName.isNotEmpty
        ? PucemApi.imageUri(item.imageBackName).toString()
        : (item.imageName.isNotEmpty ? PucemApi.imageUri(item.imageName).toString() : null);

    final hasPdf = item.pdfName.isNotEmpty;
    final pdfUrl = hasPdf ? PucemApi.fileUri(item.pdfName).toString() : null;

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
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF1F4FA),
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
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Color(0xFF5B6472),
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
                _Chip(icon: Icons.verified_outlined, label: item.resolution, color: primary),
              if (item.price > 0)
                _Chip(icon: Icons.payments_outlined, label: '\$${item.price.toStringAsFixed(2)}', color: primary),
            ],
          ),

          if (hasPdf) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _openExternal(pdfUrl!),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Abrir PDF'),
            ),
          ],

          const SizedBox(height: 18),

          // ====== HTML: Description ======
          if (item.descriptionHtml.trim().isNotEmpty) ...[
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _HtmlCard(html: item.descriptionHtml),
            const SizedBox(height: 18),
          ],

          // ====== HTML: Study plan ======
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Html(
        data: html,
        // Si el HTML trae iframes (YouTube), flutter_html no siempre los renderiza;
        // pero no rompe. Si quieres, luego hacemos soporte extra (webview).
      ),
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
    final bg = color.withOpacity(0.12);
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
