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
import 'package:watchers/widgets/banner_series.dart';

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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(height: 22),
              BannerSeries(series: [serieDaReview, serieDaReview, serieDaReview, serieDaReview, serieDaReview]),
              Container(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lançamentos recentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.chevron_right_outlined, size: 32),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resenhas populares',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.chevron_right_outlined, size: 32),
                  ),
                ],
              ),
              ReviewCard(review: meuReview),
              Container(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Listas Populares',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {},
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.chevron_right_outlined, size: 32),
                  ),
                ],
              ),
              ListPopularCard(
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
              SizedBox(height: kToolbarHeight),
            ],
          ),
        ),
      ),
    );
  }
}
