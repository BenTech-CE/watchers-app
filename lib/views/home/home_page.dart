import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/home/preview.dart';
import 'package:watchers/widgets/card_skeleton.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/banner_series.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTrendingSeries();
      _fetchTopRatedSeries();
      _fetchTrendingLists();
      _fetchTrendingReviews();
      
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchTrendingSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    await seriesProvider.getSeriesTrending();

    if (seriesProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }

  void _fetchTrendingLists() async {
    final ListsProvider listsProvider = context.read<ListsProvider>();

    await listsProvider.getTrendingLists();
  
    if (listsProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
    }
  }

  void _fetchTrendingReviews() async {
    final ReviewsProvider reviewsProvider = context.read<ReviewsProvider>();

    await reviewsProvider.getTrendingReviews();
  
    if (reviewsProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));
    }
  }



  void _fetchTopRatedSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    await seriesProvider.getSeriesTopRated();
  
    if (seriesProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }

  Widget _buildChevronAction(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox.square(dimension: 18, child: Iconify(Fa6Solid.chevron_right, color: tColorPrimary)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();
    final seriesProvider = context.watch<SeriesProvider>();
    final ReviewsProvider reviewsProvider = context.watch<ReviewsProvider>();
    final ListsProvider listsProvider = context.watch<ListsProvider>();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (seriesProvider.topRatedSeries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                child: BannerSeries(series: seriesProvider.topRatedSeries.sublist(0, 5)),
              ),
            Container(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Séries Em Alta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildChevronAction(() {
                    Navigator.pushNamed(context, "/series/best");
                  }),
                ],
              ),
            ),
            SizedBox(height: 6),
            if (seriesProvider.isLoadingTrending)
              const ListSeriesSkeleton(itemCount: 10),
            if (seriesProvider.trendingSeries.isNotEmpty && seriesProvider.isLoadingTrending == false)
              ListSeries(series: seriesProvider.trendingSeries.sublist(0, 10)),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resenhas Populares',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildChevronAction(() {
                    Navigator.pushNamed(context, "/review/trending");
                  }),
                ],
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), 
              child: reviewsProvider.isLoadingTrending
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var review in reviewsProvider.trendingReviews.sublist(0, reviewsProvider.trendingReviews.length > 3 ? 3 : reviewsProvider.trendingReviews.length))
                        ReviewCard(review: review),
                    ],
                  ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Listas Populares',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildChevronAction(() {
                    Navigator.pushNamed(context, "/list/trending");
                  }),
                ],
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), 
              child: listsProvider.isLoadingTrending
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var list in listsProvider.trendingLists.sublist(0, listsProvider.trendingLists.length > 3 ? 3 : listsProvider.trendingLists.length))
                        ListPopularCard(list: list),
                    ],
                  ),
            ),

            SizedBox(height: bottomPadding + 20),
          ],
        ),
      ),
    );
  }
}
