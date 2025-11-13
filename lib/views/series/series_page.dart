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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // get id from route
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      final String seriesId = args['id'];

      final seriesProvider = context.read<SeriesProvider>();

      series = await seriesProvider.getSerieDetails(seriesId);

    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Lançamentos Recentes", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            // Conteúdo da página de séries
          ],
        ),  
      )
    );
  }
}