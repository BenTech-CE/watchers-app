import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/mocks/genders.dart';
import 'package:watchers/core/models/auth/profile_model.dart';
import 'package:watchers/core/models/auth/user_model.dart';
import 'package:watchers/core/models/global/search_model.dart';
import 'package:watchers/core/models/global/type_filter_search.dart';
import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/genre_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/global/search_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/card_skeleton.dart';
import 'package:watchers/widgets/genre_card.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/input.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';
import 'package:watchers/widgets/series_card.dart';
import 'package:watchers/views/series/series_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<GenreModel> genres = listGenres;

  List<SerieModel> searchedSeries = [];
  List<ProfileModel> searchedUsers = [];
  List<ListModel> searchedLists = [];
  List<ReviewModel> searchedReviews = [];

  final List<String> tabsSearch = [
    "Tudo",
    "Séries",
    "Usuários",
    "Listas",
    "Reviews",
  ];
  TypeFilterSearch _selectedFilter =
      TypeFilterSearch.all; // getTypeFilterSearch

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    var _lastQuery = _searchController.text.trim();

    _searchController.addListener(() {
      final newQuery = _searchController.text.trim();

      if (newQuery == _lastQuery) return;

      _lastQuery = newQuery;

      // opcional: evita pesquisar para queries muito curtas (ex: < 3)
      if (newQuery.isNotEmpty && newQuery.length < 3) {
        if (mounted) {
          setState(() {
            _isSearching = false;
          });
        }
        return;
      }

      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      final query = _searchController.text.trim();

      if (query.isEmpty && mounted) {
        setState(() {
          _isSearching = false;
          searchedSeries.clear();
          searchedUsers.clear();
          searchedLists.clear();
          searchedReviews.clear();
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

    final SearchProvider searchProvider = context.read<SearchProvider>();

    try {
      final results = await searchProvider.getSearch(query, _selectedFilter);

      if (mounted) {
        setState(() {
          searchedSeries.clear();
          searchedUsers.clear();
          searchedReviews.clear();
          searchedLists.clear();
          if (results != null) {
            searchedSeries.addAll(results.series);
            searchedUsers.addAll(results.users);
            searchedLists.addAll(results.lists);
            searchedReviews.addAll(results.reviews);
          }
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

  @override
  Widget build(BuildContext context) {
    final seriesProvider = context.watch<SeriesProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

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
              if (_isSearching) _buildSearching(),
              if (!_isSearching)
                _buildSearchOverview(context, seriesProvider, screenWidth),

              SizedBox(height: kToolbarHeight * 2),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildSearching() {
    final SearchProvider searchProvider = context.read<SearchProvider>();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: tabsSearch.map((tab) {
              final TypeFilterSearch typeFilterSearch =
                  TypeFilterSearch.getTypeFilterSearch(tab);

              return SizedBox(
                width: 110,
                height: 40,
                child: Button(
                  label: tab,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(99),
                  onPressed: () {
                    setState(() {
                      _selectedFilter = typeFilterSearch;
                      _onSearchChanged();
                    });
                  },
                  variant: _selectedFilter == typeFilterSearch
                      ? ButtonVariant.primary
                      : ButtonVariant.inactive,
                ),
              );
            }).toList(),
          ),
        ),
        Container(height: 24),
        if (searchProvider.isLoadingSearch)
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Pesquisando...',
                    style: TextStyle(fontSize: 14, color: tColorSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // SERIES
              if (searchedSeries.isNotEmpty)
                Column(
                  children: List.generate(searchedSeries.length, (index) {
                    final series = searchedSeries[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/series/detail',
                          arguments: series.id,
                        );
                      },
                      child: Column(
                        children: [
                          LineSeparator(),
                          Container(height: 8),
                          Row(
                            spacing: 8,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 118,
                                child: SeriesCard(
                                  series: series,
                                  isSelected: false,
                                  onTap: () {},
                                ),
                              ),

                              SizedBox(
                                width: 230,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      series.name,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (series.overview.isNotEmpty)
                                      Text(
                                        series.overview,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: Color(0xff747474)),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(height: 8),
                        ],
                      ),
                    );
                  }),
                ),
              // USERS
              if (searchedUsers.isNotEmpty)
                Column(
                  children: List.generate(searchedUsers.length, (index) {
                    final user = searchedUsers[index];
                    final avatarUrl = user.avatarUrl;
                    return Column(
                      children: [
                        LineSeparator(),
                        Container(height: 8),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: ImageCard(url: avatarUrl, onTap: () {}, borderRadius: BorderRadius.circular(99),),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.fullName != null && user.fullName!.isNotEmpty ? user.fullName! : "@${user.username}",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: Color(0xffCCCCCC),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 8),
                      ],
                    );
                  }),
                ),
              // LISTS
              if (searchedLists.isNotEmpty)
                Column(
                  children: List.generate(searchedLists.length, (index) {
                    final list = searchedLists[index];
                    return Column(
                      children: [
                        LineSeparator(),
                        Container(height: 8),
                        ListPopularCard(list: list),
                        Container(height: 8),
                      ],
                    );
                  }),
                ),

              // IS EMPTY
              if (searchedSeries.isEmpty &&
                  searchedUsers.isEmpty &&
                  searchedLists.isEmpty &&
                  searchedReviews.isEmpty)
                SizedBox(
                  height: 300,
                  width: 250,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_outlined,
                          size: 64,
                          color: tColorSecondary,
                        ),
                        SizedBox(height: 16),
                        const Text(
                          "Não encontramos nenhum resultado para sua busca.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: tColorSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Column _buildSearchOverview(
    BuildContext context,
    SeriesProvider seriesProvider,
    double screenWidth,
  ) {
    final listsProvider = context.read<ListsProvider>();

    return Column(
      children: [
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
          ListSeries(series: seriesProvider.trendingSeries.sublist(0, 10)),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Buscar por gênero',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            // esse botão foi oculto pois não faz sentido uma pagina para mostrar os generos se aqui ja mostram todos.
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                onPressed: () {},
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_right_outlined, size: 32),
              ),
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
                  child: GenreCard(genre: genres[index], onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/series/genre',
                      arguments: { 'genre': genres[index] },
                    );
                  }),
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
        listsProvider.isLoadingTrending 
          ? const ListSeriesSkeleton(itemCount: 4)
          : SizedBox( 
          width: screenWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  listsProvider.trendingLists.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: screenWidth * 0.25,
                      child: ListPopularCard(
                        list: listsProvider.trendingLists[index],
                        smallComponent: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LineSeparator extends StatelessWidget {
  const LineSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: const Color.fromRGBO(159, 159, 159, 0.6),
    );
  }
}
