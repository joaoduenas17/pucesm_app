import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/news_item.dart';
import '../../services/pucem_api.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem item;
  const NewsDetailScreen({super.key, required this.item});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final WebViewController _controller;

  // Links oficiales (mismos que perfil)
  static const _links = {
    'web': 'https://pucesm.edu.ec/',
    'facebook': 'https://www.facebook.com/PUCEManabi',
    'instagram': 'https://www.instagram.com/puce_manabi/',
    'x': 'https://x.com/PUCE_SedeManabi/',
    'youtube': 'https://www.youtube.com/channel/UCV7Go41govzvVal8kOy9fBQ/',
  };

  @override
  void initState() {
    super.initState();

    // ✅ Aquí ya no repetimos el título en el HTML porque lo mostramos en UI
    final html = _wrapHtml(widget.item.descriptionHtml);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  String _wrapHtml(String bodyHtml) {
    return '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
    padding: 12px;
    color: #0f172a;
  }
  img { max-width: 100%; height: auto; border-radius: 12px; }
  a { color: #1e63ff; }
</style>
</head>
<body>
  $bodyHtml
</body>
</html>
''';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace.')),
      );
    }
  }

  String _resolveNewsWebUrl(NewsItem n) {
    // ✅ Si tu API ya trae una URL real, úsala aquí:
    // Por ejemplo: return n.url;
    // Como no la vemos en tu modelo, dejamos fallback a la sección de noticias.
    return 'https://pucesm.edu.ec/noticias';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final n = widget.item;

    final imgUrl = n.imageName.isNotEmpty
        ? PucemApi.imageUri(n.imageName).toString()
        : null;

    final webUrl = _resolveNewsWebUrl(n);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
      ),
      body: Column(
        children: [
          // ✅ Header (imagen + título + acciones)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imgUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        headers: PucemApi.defaultHeaders(isImage: true),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF1F4FA),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF1F4FA),
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                Text(
                  n.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),

                if (n.dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _MiniPill(
                    text: n.dateLabel,
                    color: cs.primary,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openUrl(webUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Ver en la web'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openUrl(_links['web']!),
                        icon: const Icon(Icons.language),
                        label: const Text('Sitio PUCE'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ✅ Contenido HTML (WebView) con scroll propio
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),

          // ✅ Footer “pro” con redes
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Redes oficiales',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: cs.primary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SocialChip(
                          icon: Icons.language,
                          label: 'Web',
                          color: cs.primary,
                          onTap: () => _openUrl(_links['web']!),
                        ),
                        _SocialChip(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: cs.primary,
                          onTap: () => _openUrl(_links['facebook']!),
                        ),
                        _SocialChip(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram',
                          color: cs.primary,
                          onTap: () => _openUrl(_links['instagram']!),
                        ),
                        _SocialChip(
                          icon: Icons.alternate_email,
                          label: 'X',
                          color: cs.primary,
                          onTap: () => _openUrl(_links['x']!),
                        ),
                        _SocialChip(
                          icon: Icons.play_circle_outline,
                          label: 'YouTube',
                          color: cs.primary,
                          onTap: () => _openUrl(_links['youtube']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
