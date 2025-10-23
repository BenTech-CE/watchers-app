import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/home_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          Center(child: Text('Descobrir')),
          Center(child: Text('Procurar')),
          Center(child: Text('Perfil')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: Color(0xff151515),
        backgroundColor: Color(0xff0d0d0d),
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house, size: 32),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.popcorn, size: 32),
            label: 'Descobrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, size: 32),
            label: 'Procurar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_rounded, size: 32),
            label: 'Perfil',
          ),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
