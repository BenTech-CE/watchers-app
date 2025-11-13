import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/texts.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  FullSeriesModel? series;
  final ScrollController _scrollController = ScrollController();
  int _appBarOpacity = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // get id from route
      final id = ModalRoute.of(context)!.settings.arguments as String;
      final String seriesId = id;

      final seriesProvider = context.read<SeriesProvider>();

      final result = await seriesProvider.getSerieDetails(seriesId);

      setState(() {
        series = result;
      });
    });
  }

  void _onScroll() {
    // Calcula opacidade baseada no scroll (0-200px)
    final offset = _scrollController.offset;
    final opacity = (offset / 150 * 255).clamp(0, 255).toInt();
    
    if (_appBarOpacity != opacity) {
      setState(() {
        _appBarOpacity = opacity;
      });
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
        ? "https://image.tmdb.org/t/p/w500${series!.backdropPath!}"
        : '';
    final posterPath = series?.posterPath != null
        ? "https://image.tmdb.org/t/p/w200${series!.posterPath!}"
        : '';

    final logoLanguagePriority = ['pt'];

    final logoPath =
        series?.images?.logos != null && series!.images!.logos!.isNotEmpty
        ? "https://image.tmdb.org/t/p/w200${series!.images!.logos!.firstWhere(
          (logo) => logoLanguagePriority.contains(logo.iso6391), orElse: () => series!.images!.logos!.first,).filePath!}"
        : '';

    final List<String> infosToDisplay = [
      if (series?.firstAirDate != null)
        series!.firstAirDate!.split('-')[0],
      if (series?.numberOfSeasons != null)
        "${series!.numberOfSeasons} ${series!.numberOfSeasons == 1 ? 'Temporada' : 'Temporadas'}",
      if (series?.numberOfEpisodes != null)
        "${series!.numberOfEpisodes} ${series!.numberOfEpisodes == 1 ? 'Episódio' : 'Episódios'}",
      if (series?.contentRatings != null &&
          series!.contentRatings!.results != null && series!.contentRatings!.results!.isNotEmpty && series!.contentRatings!.results!.any((rating) => rating.iso31661 == 'BR'))
        "+${series!.contentRatings!.results!
            .firstWhere(
              (rating) => rating.iso31661 == 'BR',
              orElse: () => ContentRatingResult(iso31661: '', rating: ''),
            )
            .rating}"
    ];

    final List<String> genresToDisplay = [
      if (series?.genres != null && series!.genres!.isNotEmpty)
        ...series!.genres!.map((genre) => genre.name!).toList(),
    ];

    // Width será 35% da tela
    const double cardWidthFraction = 0.25;
    // Aspect ratio 2:3 (width:height)
    const double aspectRatio = 2 / 3;
    // Calcula altura baseada no width e aspect ratio
    final double cardWidth =
        MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(_appBarOpacity),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          series?.name ?? '',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.0),
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
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        child: Column(
                          spacing: 16,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 16,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      if (logoPath.isNotEmpty)
                                        Container(
                                          constraints: BoxConstraints(
                                            maxHeight: 70,
                                          ),
                                          child: CachedNetworkImage(imageUrl: logoPath, height: 70, width: double.infinity, alignment: Alignment.centerLeft,)),
                                      if (logoPath.isEmpty)
                                        Text(
                                          series!.name!,
                                          style: AppTextStyles.titleLarge
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
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
                                        Text(
                                          series!.tagline!,
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (series!.overview != null &&
                                series!.overview!.isNotEmpty)
                              Text(
                                series!.overview ?? '',
                              ),
                            GestureDetector(
                              onTap: () {
                                // implementar ação
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Color(0xff161616),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'Avalie, curta, liste e muito mais',
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(
                                            color: const Color.fromARGB(185, 255, 255, 255),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color.fromARGB(185, 255, 255, 255),
                                    ),
                                  ],
                                ),
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
}
