import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/preview.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/review_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SerieModel> watchedSeries = [];
  List<SerieModel> favoritedSeries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("called again...");

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
      this.watchedSeries = watchedSeries;
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
      this.favoritedSeries = favoritedSeries;
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
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
              Column(
                children: watchedSeries
                    .map((serie) => Text(serie.name))
                    .toList(),
              ),
              Text("Séries favoritas: ${favoritedSeries.length}"),
              Column(
                children: favoritedSeries
                    .map((serie) => Text(serie.name))
                    .toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  authInfo.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Sair'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/onboarding/watched',
                  );
                },
                child: const Text('Ir para Intro'),
              ),
              ReviewCard(review: meuReview),
              Container(height: 12),
              Container(
                // decoration: BoxDecoration(
                //   border: Border(
                //     bottom: BorderSide(color: bColorCard, width: 1),
                //   ),
                // ),
                child: ListPopularCard(
                  list: ListModel(
                    id: "1",
                    name: "Minha Lista Popular",
                    createdAt: "2024-01-01",
                    likeCount: 100,
                    commentCount: 50,
                    description: "Descrição da minha lista popular",
                    type: ListType.Favorites,
                    author: ListAuthorModel(
                      id: authInfo.user!.id,
                      username: authInfo.user!.username ?? '',
                      avatarUrl: authInfo.user?.avatarUrl,
                    ),
                    thumbnails: [
                      'https://media.themoviedb.org/t/p/w600_and_h900_bestv2/7h8ZHFmx73HnEagDI6KbWAw4ea3.jpg',
                      'https://media.themoviedb.org/t/p/w600_and_h900_bestv2/6gcHdboppvplmBWxvROc96NJnmm.jpg',
                      'https://media.themoviedb.org/t/p/w600_and_h900_bestv2/vz2oBcS23lZ35LmDC7mQqThrg8v.jpg',
                      'https://media.themoviedb.org/t/p/w600_and_h900_bestv2/m3Tzf6k537PnhOEwaSRNCSxedLS.jpg',
                    ],
                  ),
                ),
              ),
              Container(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
