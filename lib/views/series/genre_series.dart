import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/genre_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';
import 'package:watchers/widgets/series_card.dart';

class GenreSeries extends StatefulWidget {
  const GenreSeries({super.key});

  @override
  State<GenreSeries> createState() => _GenreSeriesState();
}

class _GenreSeriesState extends State<GenreSeries> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<SerieModel> genreSeries = [];
  GenreModel? genre;


  @override
  void initState(){
    super.initState();

    _animationController = AnimationController( 
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seriesProvider = context.read<SeriesProvider>();

      final args = ModalRoute.of(context)!.settings.arguments as Map;
      genre = args['genre'] as GenreModel;

      _fetchGenreSeries(genre!.id);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchGenreSeries(int genreId) async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    genreSeries = await seriesProvider.getSeriesByGenre(genreId);

    if (seriesProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }


  @override
  Widget build(BuildContext context) {
    final seriesProvider = context.watch<SeriesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(genre?.name ?? "", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: seriesProvider.isLoadingByGenre ? GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 23,
                mainAxisSpacing: 23,
                childAspectRatio: 2 / 3,
              ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return SerieSkeletonCard(
                animation: _animation,
              );
            },
          ) : GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 23,
                mainAxisSpacing: 23,
                childAspectRatio: 2 / 3,
              ),
            itemCount: genreSeries.length,
            itemBuilder: (context, index) {
              final series = genreSeries[index];
              return SeriesCard(
                series: series,
                isSelected: false,
                animation: _animation,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/series/detail',
                    arguments: series.id,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}