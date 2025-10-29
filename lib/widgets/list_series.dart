import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/series_card.dart';

class ListSeries extends StatelessWidget {
  final List<SerieModel> series;
  const ListSeries({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth,
      height: 158,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: series.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              width: 96,
              height: 142,
              child: SeriesCard(
                series: series[index],
                isSelected: false,
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
