import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/series_card.dart';

class ListSeries extends StatefulWidget {
  final List<SerieModel> series;
  const ListSeries({super.key, required this.series});

  @override
  State<ListSeries> createState() => _ListSeriesState();
}

class _ListSeriesState extends State<ListSeries> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
          children: List.generate(widget.series.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: SizedBox(
                width: serieCardSize,
                height: serieCardSize * 1.5, // respeita proporção 2:3
                child: SeriesCard(
                  series: widget.series[index],
                  isSelected: false,
                  animation: _animation,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/series/detail',
                      arguments: widget.series[index].id,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}