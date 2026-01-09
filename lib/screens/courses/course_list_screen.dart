import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/pucem_api.dart';
import '../../models/course_item.dart';

class CourseListScreen extends StatefulWidget {
  final int type; // 1 = Grado | 2 = Posgrado
  final String title;

  const CourseListScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<CourseItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = PucemApi.fetchCourses(widget.type);
  }

  Future<void> _refresh() async {
    setState(() => _future = PucemApi.fetchCourses(widget.type));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<CourseItem>>(
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

          final items = snap.data ?? const <CourseItem>[];
          if (items.isEmpty) {
            return const Center(child: Text('No hay programas disponibles.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final c = items[i];
                final img = c.imageName.isNotEmpty
                    ? PucemApi.imageUri(c.imageName).toString()
                    : null;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.push('/courses/detail', extra: c),
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
                        if (img != null)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              img,
                              fit: BoxFit.cover,
                              headers: PucemApi.defaultHeaders(isImage: true),
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (c.predescription.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  c.predescription,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5B6472),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              if (c.modality.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.school, size: 16, color: primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.modality,
                                      style: TextStyle(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
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
            const Text('No se pudieron cargar los programas.'),
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
