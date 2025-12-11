import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/series_card.dart';

class RecentSeries extends StatefulWidget {
  const RecentSeries({super.key});

  @override
  State<RecentSeries> createState() => _RecentSeriesState();
}

class _RecentSeriesState extends State<RecentSeries> {
  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final seriesProvider = context.read<SeriesProvider>();

      if (seriesProvider.recentsSeries.isNotEmpty) {
        return;
      }

      _fetchRecentsSeries();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchRecentsSeries() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    await seriesProvider.getSeriesRecents();

    if (seriesProvider.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(seriesProvider.errorMessage!)));
    }
  }


  @override
  Widget build(BuildContext context) {
    final seriesProvider = context.watch<SeriesProvider>();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Lançamentos Recentes", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 23,
                mainAxisSpacing: 23,
                childAspectRatio: 2 / 3,
              ),
            itemCount: seriesProvider.recentsSeries.length,
            itemBuilder: (context, index) {
              final series = seriesProvider.recentsSeries[index];
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