import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/home/preview.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/banner_series.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SerieModel> trendingSeries = [];
  List<SerieModel> recentsSeries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("called again...");

      _fetchTrendingSeries();
      _fetchRecentsSeries();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchTrendingSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    final trendingSeries = await seriesProvider.getSeriesTrending();

    setState(() {
      if (mounted) this.trendingSeries = trendingSeries;
    });

    if (seriesProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }

  void _fetchRecentsSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    final recentsSeries = await seriesProvider.getSeriesRecents();

    setState(() {
      if (mounted) this.recentsSeries = recentsSeries;
    });

    if (seriesProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
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
              if (trendingSeries.isNotEmpty)
                BannerSeries(series: trendingSeries.sublist(0, 5)),
              Container(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lançamentos recentes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {Navigator.pushNamed(context, "/series/recent");},
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.chevron_right_outlined, size: 32),
                  ),
                ],
              ),
              if (recentsSeries.isNotEmpty)
                ListSeries(series: recentsSeries.sublist(0, 10)),
              if (recentsSeries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              SizedBox(height: 12),
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
              Column(spacing: 12, children: [ReviewCard(review: meuReview)]),
              SizedBox(height: 12),
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
              Column(
                spacing: 12,
                children: [
                  ListPopularCard(
                    list: ListModel(
                      id: "1",
                      name: "Favoritos do mês",
                      createdAt: "2024-01-01",
                      likeCount: 17,
                      commentCount: 2,
                      description: "Minhas séries favoritas que assisti esse mês! confira aí 👀",
                      type: ListType.Custom,
                      author: ListAuthorModel(
                        id: authInfo.user!.id,
                        username: 'm.claraxz',
                        avatarUrl:
                            'https://instagram.ffor13-1.fna.fbcdn.net/v/t51.2885-19/538372448_18046792706641255_6410596257831276194_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMxIn0&_nc_ht=instagram.ffor13-1.fna.fbcdn.net&_nc_cat=107&_nc_oc=Q6cZ2QHgPFXaotJhMq0KyqyOZ0XSXcBKmbnmnYlWpSGURneoJQocZlxx2iQXk2Xz8m-T0Ic&_nc_ohc=rPNLv_Bx-w8Q7kNvwHQLs26&_nc_gid=HMKB-TKdWp2tLlYH0DBv8Q&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_AffcxGyZzcfzmHCaUQiFUGoT33jRwhWDtxb6RxKQn2EJGA&oe=6908831E&_nc_sid=7a9f4b',
                      ),
                      thumbnails: [
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/el1KQzwdIm17I3A6cYPfsVIWhfX.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/vz2oBcS23lZ35LmDC7mQqThrg8v.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/Ac8ruycRXzgcsndTZFK6ouGA0FA.jpg',
                      ],
                    ),
                  ),
                  ListPopularCard(
                    list: ListModel(
                      id: "2",
                      name: "Halloween 👻",
                      createdAt: "2024-01-01",
                      likeCount: 32,
                      commentCount: 5,
                      description: null,
                      type: ListType.Custom,
                      author: ListAuthorModel(
                        id: authInfo.user!.id,
                        username: 'rizdechapeu',
                        avatarUrl:
                            'https://instagram.ffor13-1.fna.fbcdn.net/v/t51.2885-19/566502530_18296745997257312_7739221498013065072_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby44MzkuYzEifQ&_nc_ht=instagram.ffor13-1.fna.fbcdn.net&_nc_cat=100&_nc_oc=Q6cZ2QGBl1erqzR02TTif5mlhWo4hKRBmco8DVxor3WvRFss2giKAj95fk_wB6dBKCblDWw&_nc_ohc=Xb3Wv4AdT_8Q7kNvwFLKBba&_nc_gid=8viHAAr-3LjKPgK0c886nw&edm=AHzjunoBAAAA&ccb=7-5&oh=00_Aff3nOYD5QwQvi4n7K31nP2BXSYF9XAF3ygtfnVJ1QpwHA&oe=69088705&_nc_sid=ba8368',
                      ),
                      thumbnails: [
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/gMTfrLvrDaD0zrhpLZ7zXIIpKfJ.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/pbV2eLnKSIm1epSZt473UYfqaeZ.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/9j67wXS4uhPueFBwhAIoD4GxOP3.jpg',
                        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/j25YTaf8Vx5tBM7NP4ReBzDK3l7.jpg',
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: kToolbarHeight * 2),
            ],
          ),
        ),
      ),
    );
  }
}
