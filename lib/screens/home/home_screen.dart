import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/news_item.dart';
import '../../models/course_item.dart';
import '../../services/pucem_api.dart';

enum HomeSection { noticias, grado, posgrado }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSection selected = HomeSection.noticias;

  late Future<List<NewsItem>> _newsFuture;

  // ✅ NUEVO: previews de Grado / Posgrado
  late Future<List<CourseItem>> _gradoFuture;
  late Future<List<CourseItem>> _posgradoFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = PucemApi.fetchNews();
    _gradoFuture = PucemApi.fetchCourses(1);
    _posgradoFuture = PucemApi.fetchCourses(2);
  }

  Future<void> _refreshNews() async {
    setState(() => _newsFuture = PucemApi.fetchNews());
    await _newsFuture;
  }

  Future<void> _refreshGrado() async {
    setState(() => _gradoFuture = PucemApi.fetchCourses(1));
    await _gradoFuture;
  }

  Future<void> _refreshPosgrado() async {
    setState(() => _posgradoFuture = PucemApi.fetchCourses(2));
    await _posgradoFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _Header(),
          const SizedBox(height: 18),

          _PillTabs(
            selected: selected,
            onChanged: (v) => setState(() => selected = v),
          ),

          const SizedBox(height: 14),

          if (selected == HomeSection.noticias) ...[
            _NewsPreview(
              future: _newsFuture,
              onRefresh: _refreshNews,
              onSeeAll: () => context.push('/news'),
              onOpenDetail: (n) => context.push('/news/detail', extra: n),
            ),
          ] else if (selected == HomeSection.grado) ...[
            const _InfoCard(
              title: 'Carreras de Grado',
              subtitle:
                  'Explora la oferta de carreras de grado disponibles en PUCE Manabí.',
              icon: Icons.school,
            ),
            const SizedBox(height: 12),

            // ✅ NUEVO: 3 carreras + ver todas
            _CoursesPreview(
              title: 'Grado',
              future: _gradoFuture,
              onRefresh: _refreshGrado,
              onSeeAll: () => context.go('/grado'),
              onOpenDetail: (c) => context.push('/courses/detail', extra: c),
            ),

            const SizedBox(height: 12),
            _QuickButtonsRow(
              onCalendar: () => context.go('/calendar'),
              onLogin: () => context.go('/virtual'),
            ),
          ] else ...[
            const _InfoCard(
              title: 'Posgrado',
              subtitle:
                  'Explora maestrías y programas de posgrado disponibles en PUCE Manabí.',
              icon: Icons.workspace_premium,
            ),
            const SizedBox(height: 12),

            // ✅ NUEVO: 3 programas + ver todos
            _CoursesPreview(
              title: 'Posgrado',
              future: _posgradoFuture,
              onRefresh: _refreshPosgrado,
              onSeeAll: () => context.go('/posgrado'),
              onOpenDetail: (c) => context.push('/courses/detail', extra: c),
            ),

            const SizedBox(height: 12),
            _QuickButtonsRow(
              onCalendar: () => context.go('/calendar'),
              onLogin: () => context.go('/virtual'),
            ),
          ],

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ======================
// NEWS PREVIEW
// ======================

class _NewsPreview extends StatelessWidget {
  final Future<List<NewsItem>> future;
  final Future<void> Function() onRefresh;
  final VoidCallback onSeeAll;
  final void Function(NewsItem) onOpenDetail;

  const _NewsPreview({
    required this.future,
    required this.onRefresh,
    required this.onSeeAll,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Noticias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<NewsItem>>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _NewsLoading();
            }
            if (snap.hasError) {
              return _NewsError(
                message: snap.error.toString(),
                onRetry: onRefresh,
              );
            }

            final items = snap.data ?? const <NewsItem>[];
            if (items.isEmpty) {
              return const Text('No hay noticias por ahora.');
            }

            final preview = items.take(3).toList();

            return Column(
              children: [
                ...preview.map(
                  (n) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _NewsCard(
                      title: n.title,
                      predescription: n.predescription,
                      date: n.dateLabel,
                      imageUrl: n.imageName.isNotEmpty
                          ? PucemApi.imageUri(n.imageName).toString()
                          : null,
                      onTap: () => onOpenDetail(n),
                      primary: primary,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: onSeeAll,
                    icon: const Icon(Icons.article_outlined),
                    label: const Text('Ver más noticias'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String predescription;
  final String date;
  final String? imageUrl;
  final VoidCallback onTap;
  final Color primary;

  const _NewsCard({
    required this.title,
    required this.predescription,
    required this.date,
    required this.imageUrl,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
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
                      headers: PucemApi.defaultHeaders(isImage: true),
                      errorBuilder: (_, __, ___) =>
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

class _NewsLoading extends StatelessWidget {
  const _NewsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _NewsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NewsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No se pudieron cargar las noticias.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF5B6472)),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

// ======================
// COURSES PREVIEW (GRADO / POSGRADO)
// ======================

class _CoursesPreview extends StatelessWidget {
  final String title;
  final Future<List<CourseItem>> future;
  final Future<void> Function() onRefresh;
  final VoidCallback onSeeAll;
  final void Function(CourseItem) onOpenDetail;

  const _CoursesPreview({
    required this.title,
    required this.future,
    required this.onRefresh,
    required this.onSeeAll,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<CourseItem>>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No se pudieron cargar.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snap.error.toString(),
                      style: const TextStyle(color: Color(0xFF5B6472)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final items = snap.data ?? const <CourseItem>[];
            if (items.isEmpty) {
              return const Text('No hay resultados por ahora.');
            }

            final preview = items.take(3).toList();

            return Column(
              children: [
                ...preview.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _CourseCard(
                      item: c,
                      primary: primary,
                      onTap: () => onOpenDetail(c),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: onSeeAll,
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Ver todas'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseItem item;
  final Color primary;
  final VoidCallback onTap;

  const _CourseCard({
    required this.item,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ OJO: para cursos, la imagen suele venir igual por content/take/file.
    // Usamos fileUri por consistencia (y headers isImage:true).
    final img = item.imageName.isNotEmpty
        ? PucemApi.fileUri(item.imageName).toString()
        : null;

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
            if (img != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                  headers: PucemApi.defaultHeaders(isImage: true),
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (item.predescription.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.predescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: Color(0xFF5B6472),
                      ),
                    ),
                  ],
                  if (item.modality.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.school, size: 16, color: primary),
                        const SizedBox(width: 6),
                        Text(
                          item.modality,
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

// ======================
// UI PIECES
// ======================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final softBg = Theme.of(context).colorScheme.primary.withOpacity(0.10);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/logo_puce.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: primary,
                  size: 36,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'PUCE MANABÍ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: primary,
          ),
        ),
      ],
    );
  }
}

class _PillTabs extends StatelessWidget {
  final HomeSection selected;
  final ValueChanged<HomeSection> onChanged;

  const _PillTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final softBg = const Color(0xFFF1F4FA);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillButton(
              label: 'Noticias',
              active: selected == HomeSection.noticias,
              onTap: () => onChanged(HomeSection.noticias),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PillButton(
              label: 'Grado',
              active: selected == HomeSection.grado,
              onTap: () => onChanged(HomeSection.grado),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PillButton(
              label: 'Posgrado',
              active: selected == HomeSection.posgrado,
              onTap: () => onChanged(HomeSection.posgrado),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final bg = active ? primary : Colors.transparent;
    final fg = active ? Colors.white : primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final softBg = primary.withOpacity(0.10);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: softBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: Color(0xFF5B6472),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButtonsRow extends StatelessWidget {
  final VoidCallback onCalendar;
  final VoidCallback onLogin;

  const _QuickButtonsRow({required this.onCalendar, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCalendar,
            icon: const Icon(Icons.calendar_month),
            label: const Text('Calendario'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login),
            label: const Text('Iniciar sesión'),
          ),
        ),
      ],
    );
  }
}
