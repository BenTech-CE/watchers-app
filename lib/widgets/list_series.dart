import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/series_card.dart';

class ListSeries extends StatelessWidget {
  final List<SerieModel> series;
  const ListSeries({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final serieCardSize = screenWidth * 0.25; // 25% da largura da tela

    return SizedBox(
      width: screenWidth,
      height: serieCardSize * 1.5, // respeita proporção 2:3
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(series.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: SizedBox(
                width: serieCardSize,
                height: serieCardSize * 1.5, // respeita proporção 2:3
                child: SeriesCard(
                  series: series[index],
                  isSelected: false,
                  onTap: () {},
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}