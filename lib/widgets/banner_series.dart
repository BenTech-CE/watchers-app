import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/series_card.dart';

class BannerSeries extends StatelessWidget {
  final List<SerieModel> series;
  const BannerSeries({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final controller = PageController(viewportFraction: 0.42, initialPage: 0);

    return SizedBox(
      height: 202,
      child: PageView.builder(
        controller: controller,
        itemCount: series.length,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double page = controller.hasClients && controller.page != null
                  ? controller.page!
                  : controller.initialPage.toDouble();
              final double distance = (page - index).abs();
              final double scale = (1 - (distance * 0.45)).clamp(0.80, 1.0);
              final bool isFront = distance < 0.5;

              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isFront)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              // border com cor mais suave
                              border: Border(
                                top: BorderSide(
                                  color: const Color(
                                    0xFF5E5E5E,
                                  ).withOpacity(0.5),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: const Color(
                                    0xFF5E5E5E,
                                  ).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: child,
                            ),
                          )
                        else
                          child!,
                        if (!isFront)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: SeriesCard(
              series: series[index],
              isSelected: false,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
