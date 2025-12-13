import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';

class ListSeriesSkeleton extends StatefulWidget {
  final int itemCount;
  
  const ListSeriesSkeleton({
    super.key,
    this.itemCount = 8,
  });

  @override
  State<ListSeriesSkeleton> createState() => _ListSeriesSkeletonState();
}

class _ListSeriesSkeletonState extends State<ListSeriesSkeleton>
    with SingleTickerProviderStateMixin {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            spacing: 10.0,
            children: List.generate(widget.itemCount, (index) {
              return SizedBox(
                width: serieCardSize,
                height: serieCardSize * 1.5, // respeita proporção 2:3
                child: _SkeletonCard(animation: _animation),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _SkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: bColorPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradiente base
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        bColorPrimary,
                        bColorPrimary.withOpacity(0.8),
                        bColorPrimary,
                      ],
                    ),
                  ),
                ),
                // Shimmer effect animado
                Positioned(
                  left: animation.value * MediaQuery.of(context).size.width * 0.25,
                  right: -animation.value * MediaQuery.of(context).size.width * 0.25,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // Ícone de imagem no centro
                Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SerieSkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const SerieSkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: bColorPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gradiente base
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        bColorPrimary,
                        bColorPrimary.withOpacity(0.8),
                        bColorPrimary,
                      ],
                    ),
                  ),
                ),
                // Shimmer effect animado
                Positioned(
                  left: animation.value * MediaQuery.of(context).size.width * 0.25,
                  right: -animation.value * MediaQuery.of(context).size.width * 0.25,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
                // Ícone de imagem no centro
                Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
