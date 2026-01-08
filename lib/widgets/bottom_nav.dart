import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  final Widget child;

  const BottomNav({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/virtual')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  String _titleFromIndex(int index) {
    switch (index) {
      case 1:
        return 'Calendario';
      case 2:
        return 'Entorno virtual';
      case 3:
        return 'Perfil';
      default:
        return 'Inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int index = _indexFromLocation(location);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFromIndex(index)),
        centerTitle: true,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/calendar');
              break;
            case 2:
              context.go('/virtual');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Entorno',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
