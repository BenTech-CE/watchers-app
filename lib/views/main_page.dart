import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/views/home/home_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:watchers/views/home/preview.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:watchers/views/profile/profile_page.dart';
import 'package:watchers/views/search/search_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

const String iconProfile =
    '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" fill-rule="evenodd" d="M8 7a4 4 0 1 1 8 0a4 4 0 0 1-8 0m0 6a5 5 0 0 0-5 5a3 3 0 0 0 3 3h12a3 3 0 0 0 3-3a5 5 0 0 0-5-5z" clip-rule="evenodd"/></svg>';

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();

      if (authProvider.user!.createdAt.difference(DateTime.now()).inMinutes.abs() < 1) {
        Navigator.pushNamed(context, '/onboarding/watched');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = Theme.of(context).navigationBarTheme.iconTheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomePage(), /*Preview(),*/ SearchPage(), ProfilePage()],
      ),
      extendBody: true,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            indicatorColor: Color(0xff151515).withOpacity(0.6),
            backgroundColor: Color(0xff0d0d0d).withOpacity(0.8),
            elevation: 0,
            destinations: [
              NavigationDestination(
                icon: Iconify(
                  Ion.home,
                  size: 30,
                  color: iconTheme?.resolve({
                    if (_selectedIndex == 0) WidgetState.selected,
                  })?.color,
                ),
                label: 'Início',
              ),
              /*NavigationDestination(
                icon: Icon(LucideIcons.popcorn, size: 30),
                label: 'Descobrir',
              ),*/
              NavigationDestination(
                icon: Icon(Icons.search, size: 30),
                label: 'Procurar',
              ),
              NavigationDestination(
                icon: Iconify(
                  iconProfile,
                  size: 30,
                  color: iconTheme?.resolve({
                    if (_selectedIndex == 2) WidgetState.selected,
                  })?.color,
                ),
                label: 'Perfil',
              ),
            ],
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
