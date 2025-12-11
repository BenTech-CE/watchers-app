import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/series_card.dart';

class BestSeries extends StatefulWidget {
  const BestSeries({super.key});

  @override
  State<BestSeries> createState() => _BestSeriesState();
}

class _BestSeriesState extends State<BestSeries> {
  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seriesProvider = context.read<SeriesProvider>();

      if (seriesProvider.trendingSeries.isNotEmpty) {
        return;
      }

      _fetchTrendingSeries();
    });
  }

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Melhores avaliadas", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 23,
                mainAxisSpacing: 23,
                childAspectRatio: 2 / 3,
              ),
            itemCount: seriesProvider.trendingSeries.length,
            itemBuilder: (context, index) {
              final series = seriesProvider.trendingSeries[index];
              return SeriesCard(
                series: series,
                isSelected: false,
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