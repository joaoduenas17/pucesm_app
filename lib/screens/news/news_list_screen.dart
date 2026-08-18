import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/preference_keys.dart';
import '../../models/news_item.dart';
import '../../services/pucem_api.dart';
import '../../services/notification_service.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> _future;

  bool _checkedNotificationsThisLoad = false;

  @override
  void initState() {
    super.initState();
    _future = _fetchAndMaybeNotify();
  }

  Future<void> _refresh() async {
    setState(() {
      _checkedNotificationsThisLoad = false;
      _future = _fetchAndMaybeNotify();
    });
    await _future;
  }

  Future<List<NewsItem>> _fetchAndMaybeNotify() async {
    final items = await PucemApi.fetchNews();

    // Evita notificar repetido por rebuilds
    if (!_checkedNotificationsThisLoad) {
      _checkedNotificationsThisLoad = true;
      await _maybeNotifyForNews(items);
    }

    return items;
  }

  /// Notifica si:
  /// - hay noticias
  /// - notificaciones globales activas
  /// - notificaciones de noticias activas
  /// - la noticia "más nueva" cambió vs lo guardado
  Future<void> _maybeNotifyForNews(List<NewsItem> items) async {
    if (items.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final masterOn = prefs.getBool(PreferenceKeys.masterNotifications) ?? false;
    final newsOn = prefs.getBool(PreferenceKeys.newsNotifications) ?? true;

    if (!masterOn || !newsOn) return;

    // Tomamos la primera noticia (normalmente viene ordenada por más reciente)
    final latest = items.first;

    // Fingerprint estable (si el API no trae ID)
    final fingerprint = _newsFingerprint(latest);

    final lastNotified = prefs.getString(PreferenceKeys.newsLastNotified) ?? '';
    if (fingerprint == lastNotified) return; // anti-spam

    // La primera carga fija una línea base; no presenta contenido ya publicado
    // como si fuera una noticia nueva.
    await prefs.setString(PreferenceKeys.newsLastNotified, fingerprint);
    if (lastNotified.isEmpty) return;

    final id = latest.id & 0x7FFFFFFF;

    try {
      await NotificationService.showInstant(
        id: id,
        title: 'Nueva noticia PUCE Manabí',
        body: latest.title,
      );
    } catch (error, stackTrace) {
      // Un fallo de notificación no debe impedir consultar las noticias.
      debugPrint('No se pudo mostrar la notificación: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _newsFingerprint(NewsItem n) {
    return '${n.id}|${n.dateLabel}|${n.title}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias')),
      body: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorState(
              message: snap.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snap.data ?? const <NewsItem>[];
          if (items.isEmpty) {
            return const Center(child: Text('No hay noticias por ahora.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = items[i];
                final img = n.imageName.isNotEmpty
                    ? PucemApi.imageUri(n.imageName).toString()
                    : null;

                return _NewsCard(
                  title: n.title,
                  predescription: n.predescription,
                  date: n.dateLabel,
                  imageUrl: img,
                  onTap: () => context.push('/news/detail', extra: n),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String predescription;
  final String date;
  final String? imageUrl;
  final VoidCallback onTap;

  const _NewsCard({
    required this.title,
    required this.predescription,
    required this.date,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) ...[
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      headers: PucemApi.defaultHeaders(isImage: true), // ✅
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) =>
                          const Center(child: Icon(Icons.image_not_supported)),
                    ),
                  ),
                  if (date.isNotEmpty)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (predescription.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      predescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 10),
            const Text('No se pudieron cargar las noticias.'),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
