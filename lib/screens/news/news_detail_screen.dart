import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/news_item.dart';
import '../../services/pucem_api.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem item;

  const NewsDetailScreen({super.key, required this.item});

  static const _links = {
    'web': 'https://pucem.edu.ec/',
    'facebook': 'https://www.facebook.com/PUCEManabi',
    'instagram': 'https://www.instagram.com/puce_manabi/',
    'x': 'https://x.com/PUCE_SedeManabi/',
    'youtube': 'https://www.youtube.com/channel/UCV7Go41govzvVal8kOy9fBQ/',
  };

  Future<void> _openUrl(BuildContext context, String url) async {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) {
      _showLinkError(context);
      return;
    }

    final uri = parsed.hasScheme
        ? parsed
        : Uri.parse(_links['web']!).resolveUri(parsed);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) _showLinkError(context);
  }

  void _showLinkError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace.')),
    );
  }

  String _resolveNewsWebUrl(NewsItem news) {
    final slug = news.urlSlug.trim();
    if (slug.isEmpty) return 'https://pucem.edu.ec/noticias';

    final absolute = Uri.tryParse(slug);
    if (absolute != null && absolute.hasScheme) return absolute.toString();

    var path = slug.startsWith('/') ? slug : '/$slug';
    if (!path.startsWith('/noticias/')) path = '/noticias$path';
    return Uri.https('pucem.edu.ec', path).toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageUrl = item.imageName.isNotEmpty
        ? PucemApi.imageUri(item.imageName).toString()
        : null;
    final webUrl = _resolveNewsWebUrl(item);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    headers: PucemApi.defaultHeaders(isImage: true),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            if (item.dateLabel.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: _MiniPill(text: item.dateLabel, color: colors.primary),
              ),
            ],
            const SizedBox(height: 14),
            _ActionButtons(
              onOpenNews: () => _openUrl(context, webUrl),
              onOpenSite: () => _openUrl(context, _links['web']!),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (item.descriptionHtml.trim().isNotEmpty)
              Html(
                data: item.descriptionHtml,
                shrinkWrap: true,
                onLinkTap: (url, _, _) {
                  if (url != null && url.trim().isNotEmpty) {
                    _openUrl(context, url);
                  }
                },
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    color: colors.onSurface,
                    fontSize: FontSize(16),
                    lineHeight: LineHeight.number(1.25),
                  ),
                  'p': Style(margin: Margins.only(bottom: 12)),
                  'a': Style(
                    color: colors.primary,
                    textDecoration: TextDecoration.underline,
                  ),
                },
              )
            else if (item.predescription.trim().isNotEmpty)
              Text(
                item.predescription,
                style: const TextStyle(fontSize: 16, height: 1.5),
              )
            else
              Text(
                'Esta noticia no tiene contenido adicional disponible.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            const SizedBox(height: 18),
            Card(
              margin: EdgeInsets.zero,
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
                        color: colors.primary.withValues(alpha: 0.9),
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
                          color: colors.primary,
                          onTap: () => _openUrl(context, _links['web']!),
                        ),
                        _SocialChip(
                          icon: Icons.facebook,
                          label: 'Facebook',
                          color: colors.primary,
                          onTap: () => _openUrl(context, _links['facebook']!),
                        ),
                        _SocialChip(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram',
                          color: colors.primary,
                          onTap: () => _openUrl(context, _links['instagram']!),
                        ),
                        _SocialChip(
                          icon: Icons.alternate_email,
                          label: 'X',
                          color: colors.primary,
                          onTap: () => _openUrl(context, _links['x']!),
                        ),
                        _SocialChip(
                          icon: Icons.play_circle_outline,
                          label: 'YouTube',
                          color: colors.primary,
                          onTap: () => _openUrl(context, _links['youtube']!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onOpenNews;
  final VoidCallback onOpenSite;

  const _ActionButtons({required this.onOpenNews, required this.onOpenSite});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 390;
        final newsButton = OutlinedButton.icon(
          onPressed: onOpenNews,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Ver en la web'),
        );
        final siteButton = ElevatedButton.icon(
          onPressed: onOpenSite,
          icon: const Icon(Icons.language),
          label: const Text('Sitio PUCE'),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [newsButton, const SizedBox(height: 10), siteButton],
          );
        }

        return Row(
          children: [
            Expanded(child: newsButton),
            const SizedBox(width: 12),
            Expanded(child: siteButton),
          ],
        );
      },
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
        color: color.withValues(alpha: 0.10),
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
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
