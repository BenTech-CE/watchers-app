import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<SerieModel> watchedSeries = [];
  List<SerieModel> favoritedSeries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWatchedSeries();
      _fetchFavoritedSeries();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchWatchedSeries() async {
    final ListsProvider listsProvider = context.read<ListsProvider>();

    final watchedSeries = await listsProvider.getListSeries("watched");

    setState(() {
      if (mounted) this.watchedSeries = watchedSeries;
    });

    if (listsProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
    }
  }

  void _fetchFavoritedSeries() async {
    final ListsProvider listsProvider = context.read<ListsProvider>();

    final favoritedSeries = await listsProvider.getListSeries("favorites");

    setState(() {
      if (mounted) this.favoritedSeries = favoritedSeries;
    });

    if (listsProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: SizedBox(
          width: 138,
          height: 28,
          child: SvgPicture.asset("assets/logo/logowatchers.svg"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Usuário atual:'),
            Text('Username: ${authInfo.user?.username}'),
            Text('E-mail: ${authInfo.user?.email}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "AccessToken: ${authInfo.accessToken?.substring(0, 15)}...",
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: authInfo.accessToken!),
                    );
                  },
                  icon: Icon(Icons.copy),
                  iconSize: 24,
                ),
              ],
            ),
            Text("Séries assistidas: ${watchedSeries.length}"),
            /*Column(
                  children: watchedSeries
                      .map((serie) => Text(serie.name))
                      .toList(),
                ),*/
            Text("Séries favoritas: ${favoritedSeries.length}"),
            /*Column(
                  children: favoritedSeries
                      .map((serie) => Text(serie.name))
                      .toList(),
                ),*/
            ElevatedButton(
              onPressed: () {
                authInfo.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboarding/watched');
              },
              child: const Text('Ir para Intro'),
            ),
          ],
        ),
      ),
    );
  }
}
