import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/series_card.dart';

class BannerSeries extends StatelessWidget {
  final List<SerieModel> series;
  const BannerSeries({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    // Width será 35% da tela
    const double cardWidthFraction = 0.35;
    // Aspect ratio 2:3 (width:height)
    const double aspectRatio = 2 / 3;
    // Calcula altura baseada no width e aspect ratio
    final double cardWidth = MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    // Cria um grande offset inicial para simular scroll infinito
    // e começar com o primeiro elemento centralizado
    const int virtualOffset = 10000;
    final int initialPage = virtualOffset;

    final controller = PageController(
      viewportFraction: cardWidthFraction + 0.05,
      initialPage: initialPage,
    );

    return SizedBox(
      height: cardHeight * 1.1, // Altura do container com margem
      child: PageView.builder(
        controller: controller,
        itemCount: null, // Infinito
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          // Usa módulo para circular pela lista
          final int actualIndex = index % series.length;
          
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
                    width: cardWidth,
                    height: cardHeight,
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
              series: series[actualIndex],
              isSelected: false,
              onTap: () {
                Navigator.pushNamed(context, '/series/detail', arguments: series[actualIndex].id);
              },
            ),
          );
        },
      ),
    );
  }
}
