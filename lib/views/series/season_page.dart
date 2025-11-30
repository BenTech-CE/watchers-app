import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/mocks/genders.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/series/full_season_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/views/series/series_options_sheet.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/review_card_in_serie.dart';
import 'package:watchers/widgets/series_card.dart';
import 'package:watchers/widgets/stars_chart.dart';
import 'package:path/path.dart' as path;

class SeasonPage extends StatefulWidget {
  const SeasonPage({super.key});

  @override
  State<SeasonPage> createState() => _SeasonPageState();
}

class _SeasonPageState extends State<SeasonPage> {
  FullSeasonModel? season;
  FullSeriesModel? series;

  final ScrollController _scrollController = ScrollController();
  int _appBarOpacity = 0;
  double _gradientOpacity = 0.0;

  int _indexedStackIndex = 0;

  final double crewProfilePictureSize = 60.0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // get id from route
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final String seriesId = args['seriesId'];
      final String seasonNumber = args['seasonNumber'];
      final FullSeriesModel series = args['series'];
      final seriesProvider = context.read<SeriesProvider>();
      final userProvider = context.read<UserProvider>();

      userProvider.clearCurrentUserInteractionData("season");

      final result = await seriesProvider.getSeasonDetails(
        seriesId,
        seasonNumber,
      );

      if (mounted) {
        setState(() {
          season = result;
          this.series = series;
        });

        userProvider.setCurrentUserInteractionData(
          "season",
          result?.userData ?? UserInteractionData.empty(),
        );
      }
    });
  }

  void _onScroll() {
    // Calcula opacidade baseada no scroll (0-200px)
    final offset = _scrollController.offset;
    final gradientOp = (offset / 150).clamp(0.0, 1.0);

    if (_gradientOpacity != gradientOp) {
      setState(() {
        _appBarOpacity = gradientOp == 1 ? 255 : 0;
        _gradientOpacity = gradientOp;
      });
    }
  }

  String _formatEpisodeAirDate(String airDate) {
    try {
      final date = DateTime.parse(airDate);

      final isFuture = date.isAfter(DateTime.now());

      return isFuture
          ? 'Lançará em ${date.day}/${date.month}/${date.year}'
          : 'Lançado em ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Data de exibição desconhecida';
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdropPath = series?.backdropPath != null
        ? "https://image.tmdb.org/t/p/w1280${series!.backdropPath!}"
        : '';
    final posterPath = season?.posterPath != null
        ? "https://image.tmdb.org/t/p/w500${season!.posterPath!}"
        : '';

    final logoLanguagePriority = ['pt'];

    final logoPath =
        series?.images?.logos != null && series!.images!.logos!.isNotEmpty
        ? "https://image.tmdb.org/t/p/w500${series!.images!.logos!.firstWhere((logo) => logoLanguagePriority.contains(logo.iso6391), orElse: () => series!.images!.logos!.first).filePath!}"
        : '';

    final willShowLogo =
        logoPath.isNotEmpty && path.extension(logoPath).toLowerCase() != '.svg';

    final List<String> infosToDisplay = [
      if (season?.airDate != null) season!.airDate!.split('-')[0],
      if (season?.episodes.length != null)
        "${season!.episodes.length} ${season!.episodes.length == 1 ? 'Episódio' : 'Episódios'}",
      if (series?.contentRatings != null &&
          series!.contentRatings!.results != null &&
          series!.contentRatings!.results!.isNotEmpty &&
          series!.contentRatings!.results!.any(
            (rating) => rating.iso31661 == 'BR',
          ))
        "+${series!.contentRatings!.results!.firstWhere(
          (rating) => rating.iso31661 == 'BR',
          orElse: () => ContentRatingResult(iso31661: '', rating: ''),
        ).rating}",
    ];

    final List<String> genresToDisplay = [
      if (series?.genres != null && series!.genres!.isNotEmpty)
        ...series!.genres!.map(
          (genre) => listGenres.firstWhere((g) => g.id == genre.id).name,
        ),
    ];

    // variaveis para o taman ho do poster (25% da tela, proporção 2:3)
    const double cardWidthFraction = 0.25;
    const double aspectRatio = 2 / 3;
    final double cardWidth =
        MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    // abas de detalhes
    final List<String> detailTabs = ['Episódios', 'Detalhes', 'Resenhas'];

    void _sheetReview(BuildContext context) {
      final userProvider = context.read<UserProvider>();
      //userProvider.setCurrentUserInteractionData(season?.userData ?? UserInteractionData.empty());

      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (BuildContext context) => SeriesOptionsSheet(
          title: season?.name ?? 'Temporada ${season?.seasonNumber ?? ''}',
          id: series?.id.toString() ?? '',
          scope: "season",
          isSeries: false,
          seasonNumber: season?.seasonNumber,
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(_appBarOpacity),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          season?.name ?? 'Temporada ${season?.seasonNumber ?? ''}',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: series != null
          ? Stack(
              children: [
                // Imagem de fundo fixa
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(1),
                          Colors.black.withOpacity(_gradientOpacity),
                          Colors.black.withOpacity(_gradientOpacity),
                          Colors.black.withOpacity(_gradientOpacity),
                          Colors.black.withOpacity(1),
                        ],
                        stops: const [0.0, 0.3, 0.4, 0.5, 1.0],
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: backdropPath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 350,
                    ),
                  ),
                ),
                // Conteúdo scrollável
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Espaço vazio que permite scroll até o topo
                      const SizedBox(height: 300),
                      // Container com conteúdo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          kBottomNavigationBarHeight + 16,
                        ),
                        child: Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                spacing: 16,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 16,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: posterPath,
                                          width: cardWidth,
                                          height: cardHeight,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (willShowLogo)
                                              Container(
                                                constraints: BoxConstraints(
                                                  maxHeight: 70,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: logoPath,
                                                  height: 70,
                                                  width: double.infinity,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                            if (!willShowLogo)
                                              Text(
                                                series!.name!,
                                                style: AppTextStyles.titleLarge
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            if (infosToDisplay.isNotEmpty)
                                              Text(
                                                infosToDisplay.join(" • "),
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      color: Color(0xff747474),
                                                    ),
                                              ),
                                            if (genresToDisplay.isNotEmpty)
                                              Text(
                                                genresToDisplay.join(", "),
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      color: Color(0xff747474),
                                                    ),
                                              ),
                                            if (series!.tagline != null &&
                                                series!.tagline!.isNotEmpty)
                                              Text(series!.tagline!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (season!.overview != null &&
                                      season!.overview!.isNotEmpty)
                                    Text(season!.overview ?? ''),
                                  GestureDetector(
                                    onTap: () {
                                      _sheetReview(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xff161616),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            'Avalie, curta, liste e muito mais',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color: const Color.fromARGB(
                                                    185,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color.fromARGB(
                                              185,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Avaliações",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: tColorSecondary,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "0 ",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: tColorSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.favorite_rounded,
                                        color: tColorSecondary,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  StarsChart(
                                    data: season?.starDistribution ?? [],
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  spacing: 8,
                                  children: detailTabs.map((tab) {
                                    final index = detailTabs.indexOf(tab);

                                    return SizedBox(
                                      width: 120,
                                      height: 40,
                                      child: Button(
                                        label: tab,
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(99),
                                        onPressed: () {
                                          setState(() {
                                            _indexedStackIndex = index;
                                          });
                                        },
                                        variant: _indexedStackIndex == index
                                            ? ButtonVariant.primary
                                            : ButtonVariant.inactive,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                children: [
                                  // Índice 0: _buildEpisodes
                                  Visibility(
                                    visible: _indexedStackIndex == 0,
                                    maintainState: true,
                                    maintainSize: false,
                                    child: _buildEpisodes(),
                                  ),
                                  // Índice 1: _buildDetails
                                  Visibility(
                                    visible: _indexedStackIndex == 1,
                                    maintainState: true,
                                    maintainSize: false,
                                    child: _buildDetails(),
                                  ),
                                  // Índice 2: _buildReviews
                                  Visibility(
                                    visible: _indexedStackIndex == 2,
                                    maintainState: true,
                                    maintainSize: false,
                                    child: _buildReviews(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDetails() {
    final List<String> genresToDisplay = [
      if (series?.genres != null && series!.genres!.isNotEmpty)
        ...series!.genres!.map(
          (genre) => listGenres.firstWhere((g) => g.id == genre.id).name,
        ),
    ];

    final crewList = series?.credits?.crew ?? <Crew>[];

    final seenDirectorIds = <int>{};
    final seenWriterIds = <int>{};

    final List<Crew> directors = crewList.where((crew) {
      final isDirector = crew.knownForDepartment == 'Directing';

      return isDirector && crew.id != null && seenDirectorIds.add(crew.id!);
    }).toList();

    final List<Crew> writers = crewList.where((crew) {
      final isWriter = crew.knownForDepartment == 'Writing';

      return isWriter && crew.id != null && seenWriterIds.add(crew.id!);
    }).toList();

    return Column(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (series!.productionCompanies != null &&
            series!.productionCompanies!.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Produtoras: ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: series!.productionCompanies!
                      .map((e) => e.name)
                      .join(', '),
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        if (series!.originCountry != null && series!.originCountry!.isNotEmpty)
          if (directors.isNotEmpty)
            Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Diretor${directors.length > 1 ? 'es' : ''}:",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: directors
                        .map(
                          (director) => SizedBox(
                            width: crewProfilePictureSize,
                            child: Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: crewProfilePictureSize,
                                  height: crewProfilePictureSize,
                                  child: ImageCard(
                                    url:
                                        "https://image.tmdb.org/t/p/w154${director.profilePath}",
                                    onTap: () {},
                                  ),
                                ),
                                Text(
                                  director.name ?? '',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
        if (writers.isNotEmpty)
          Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Roteirista${writers.length > 1 ? 's' : ''}:",
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: writers
                      .map(
                        (writer) => SizedBox(
                          width: crewProfilePictureSize,
                          child: Column(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: crewProfilePictureSize,
                                height: crewProfilePictureSize,
                                child: ImageCard(
                                  url:
                                      "https://image.tmdb.org/t/p/w154${writer.profilePath}",
                                  onTap: () {},
                                ),
                              ),
                              Text(
                                writer.name ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'País de origem: ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: series!.originCountry!.join(', '),
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
        if (genresToDisplay.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Gêneros: ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: genresToDisplay.join(', '),
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lançamento: ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: season!.airDate ?? 'A ser anunciado',
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodes() {
    // variaveis para o taman ho do poster (25% da tela, proporção 2:3)
    const double cardWidthFraction = 0.2;
    const double aspectRatio = 4 / 3;
    final double cardWidth =
        MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    return Column(
      spacing: 16,
      children: [
        for (var episode in season!.episodes)
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/series/episode',
                arguments: {
                  'episode': episode,
                  'series': series,
                  'seasonPosterPath': season!.posterPath,
                },
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: ImageCard(
                    url: "https://image.tmdb.org/t/p/w154${episode.stillPath}",
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${episode.episodeNumber}. ',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: tColorGray,
                                    ),
                                  ),
                                  TextSpan(
                                    text: episode.name ?? 'Sem título',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: tColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: tColorPrimary,
                          ),
                        ],
                      ),

                      Text(
                        episode.overview != null && episode.overview!.isNotEmpty
                            ? episode.overview!
                            : (episode.airDate != null
                                  ? _formatEpisodeAirDate(episode.airDate!)
                                  : "Sem descrição disponível."),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Color(0xff747474),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        RichText(
          text: TextSpan(
            text: "Resenhas de ",
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text:
                    "${season!.name ?? "Temporada ${season!.seasonNumber ?? ''}"}",
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ...season?.reviews
                ?.map((review) => ReviewCardInSerie(review: review))
                .toList() ??
            [],
      ],
    );
  }
}
