import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/mocks/genders.dart';
import 'package:watchers/core/models/auth/user_model.dart';
import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/genre_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/genre_card.dart';
import 'package:watchers/widgets/input.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<GenreModel> genres = listGenres;
  List<ListModel> listsPopular = [
    ListModel(
      id: "1",
      name: "Favoritos do mês",
      createdAt: "2024-01-01",
      likeCount: 17,
      commentCount: 2,
      description: null,
      type: ListType.Custom,
      author: ListAuthorModel(
        id: "123",
        username: 'm.claraxz',
        avatarUrl: 'https://picsum.photos/200',
      ),
      thumbnails: [
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/el1KQzwdIm17I3A6cYPfsVIWhfX.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/vz2oBcS23lZ35LmDC7mQqThrg8v.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/Ac8ruycRXzgcsndTZFK6ouGA0FA.jpg',
      ],
    ),
    ListModel(
      id: "2",
      name: "Halloween 👻",
      createdAt: "2024-01-01",
      likeCount: 32,
      commentCount: 5,
      description: null,
      type: ListType.Custom,
      author: ListAuthorModel(
        id: "345",
        username: 'rizdechapeu',
        avatarUrl: 'https://picsum.photos/200',
      ),
      thumbnails: [
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/gMTfrLvrDaD0zrhpLZ7zXIIpKfJ.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/pbV2eLnKSIm1epSZt473UYfqaeZ.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/9j67wXS4uhPueFBwhAIoD4GxOP3.jpg',
        'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/j25YTaf8Vx5tBM7NP4ReBzDK3l7.jpg',
      ],
    ),
  ];

  List<SerieModel> searchedSeries = [];
  List<UserModel> searchedUsers = [];
  List<ReviewModel> searchedReviews = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_fetchTrendingSeries();
      // comentado pois a home ja faz essa chamada, a resposta já está no provider.
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();

      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          searchedSeries.clear();
          // searchedUsers.clear();
          // searchedReviews.clear();
        });
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    try {
      final results = await seriesProvider.getSeriesSearch(query);

      if (mounted) {
        setState(() {
          searchedSeries.clear();
          // searchedUsers.clear();
          // searchedReviews.clear();
          searchedSeries.addAll(results);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao pesquisar séries: $e")));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _fetchTrendingSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    await seriesProvider.getSeriesTrending();

    if (seriesProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final seriesProvider = context.watch<SeriesProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

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
              Container(height: 32),
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Consumer<SeriesProvider>(
                  builder: (context, provider, child) {
                    return TextInputWidget(
                      label: "Procure por séries, listas, usuários...",
                      controller: _searchController,
                      icon: provider.isLoadingSearch && _isSearching
                          ? Icons.hourglass_empty
                          : Icons.search,
                      labelAsHint: true,
                      hintStyle: AppTextStyles.labelLarge.copyWith(
                        color: tColorSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              Container(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Melhores avaliados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/series/best");
                    },
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.chevron_right_outlined, size: 32),
                  ),
                ],
              ),
              if (seriesProvider.isLoadingTrending)
                const ListSeriesSkeleton(itemCount: 10),
              if (seriesProvider.trendingSeries.isNotEmpty &&
                  seriesProvider.isLoadingTrending == false)
                ListSeries(
                  series: seriesProvider.trendingSeries.sublist(0, 10),
                ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Melhores gêneros',
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
              SizedBox(
                width: screenWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      genres.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GenreCard(
                          genre: genres[index],
                          onTap: () {},
                          
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Listas para você',
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
              SizedBox(
                width: screenWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        listsPopular.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: SizedBox(
                            width: screenWidth * 0.25,
                            child: ListPopularCard(
                              list: listsPopular[index],
                              smallComponent: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: kToolbarHeight * 2),
            ],
          ),
        ),
      ),
    );
  }
}
