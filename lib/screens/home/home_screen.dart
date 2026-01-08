import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum HomeSection { noticias, grado, posgrado }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSection selected = HomeSection.noticias;

  // Mock data (luego lo conectamos a backend / web)
  final List<_NewsItem> news = const [
    _NewsItem(
      title: 'FIRMA DE CONVENIO CON HOTEL ORO VERDE PORTOVIEJO',
      date: '2025-07-30 01:54',
      imageUrl: 'https://picsum.photos/seed/puce1/900/500',
    ),
    _NewsItem(
      title: 'RESULTADOS GENERALES FASE MÉRITO Y FASE OPOSICIÓN',
      date: '2025-07-29 10:40',
      imageUrl: 'https://picsum.photos/seed/puce2/900/500',
    ),
    _NewsItem(
      title: 'PRIMERA FERIA DE EMPLEABILIDAD EN EL CAMPUS MANTA',
      date: '2025-07-22 12:18',
      imageUrl: 'https://picsum.photos/seed/puce3/900/500',
    ),
  ];

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
            ...news.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _NewsCard(item: n),
                )),
          ] else if (selected == HomeSection.grado) ...[
            const _InfoCard(
              title: 'Carreras de Grado',
              subtitle:
                  'Aquí mostraremos la información de carreras de grado (lista, detalle, contacto, etc.).',
              icon: Icons.school,
            ),
            const SizedBox(height: 12),
            _QuickButtonsRow(
              onCalendar: () => _go('/calendar'),
              onLogin: () => _go('/virtual'),
            ),
          ] else ...[
            const _InfoCard(
              title: 'Posgrado',
              subtitle:
                  'Aquí mostraremos la información de programas de posgrado (maestrías, requisitos, etc.).',
              icon: Icons.workspace_premium,
            ),
            const SizedBox(height: 12),
            _QuickButtonsRow(
              onCalendar: () => _go('/calendar'),
              onLogin: () => _go('/virtual'),
            ),
          ],

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  void _go(String path) => context.go(path);
}

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
    final softBg = const Color(0xFFF1F4FA); // neutro (no compite con el primario)

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

class _NewsCard extends StatelessWidget {
  final _NewsItem item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.date,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
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
                const Text(
                  // mantenemos el mismo estilo neutro para lectura
                  '',
                ),
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

class _NewsItem {
  final String title;
  final String date;
  final String imageUrl;

  const _NewsItem({
    required this.title,
    required this.date,
    required this.imageUrl,
  });
}
