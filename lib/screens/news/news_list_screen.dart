import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/news_item.dart';
import '../../services/pucem_api.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = PucemApi.fetchNews();
  }

  Future<void> _refresh() async {
    setState(() => _future = PucemApi.fetchNews());
    await _future;
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
                      headers: PucemApi.defaultHeaders(), // ✅ CLAVE
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
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
                          style: const TextStyle(
                            color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: Color(0xFF5B6472),
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
              style: const TextStyle(color: Color(0xFF5B6472)),
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

