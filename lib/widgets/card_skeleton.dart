import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart'; // Assumindo que sizePadding vem daqui

class ListReviewsSkeleton extends StatefulWidget {
  final int itemCount;

  const ListReviewsSkeleton({
    super.key,
    this.itemCount = 5, // Geralmente reviews são verticais, então 5 é um bom default
  });

  @override
  State<ListReviewsSkeleton> createState() => _ListReviewsSkeletonState();
}

class _ListReviewsSkeletonState extends State<ListReviewsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Mesma lógica de animação do seu exemplo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Espaçamento vertical entre cards
          child: _SkeletonReviewItem(animation: _animation),
        );
      }),
    );
  }
}

class _SkeletonReviewItem extends StatelessWidget {
  final Animation<double> animation;

  const _SkeletonReviewItem({required this.animation});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final serieCardSize = screenWidth * 0.25; // 25% da largura (Mesma do ReviewCard)
    final cardColor = Colors.grey[900]; // Mesma cor do ReviewCard

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: sizePadding, // Se seu Flutter for < 3.24, use SizedBox no meio
          children: [
            // --- 1. Fake Poster (Esquerda) ---
            _ShimmerShape(
              animation: animation,
              width: serieCardSize,
              height: serieCardSize * 1.5,
              borderRadius: 12,
            ),

            const SizedBox(width: 12), // Espaçamento similar ao sizePadding

            // --- 2. Fake Info (Direita) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  
                  // Título (Linha grossa)
                  _ShimmerShape(
                    animation: animation,
                    width: double.infinity,
                    height: 20,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),

                  // Badge (Temporada/Episódio)
                  _ShimmerShape(
                    animation: animation,
                    width: 100,
                    height: 16,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 12),

                  // Linha do Usuário + Estrelas
                  Row(
                    children: [
                      // Avatar (Círculo)
                      _ShimmerShape(
                        animation: animation,
                        width: 24,
                        height: 24,
                        borderRadius: 12, // Metade do width para ser redondo
                      ),
                      const SizedBox(width: 8),
                      // Nome do usuário
                      _ShimmerShape(
                        animation: animation,
                        width: 60,
                        height: 12,
                        borderRadius: 4,
                      ),
                      const Spacer(),
                      // Estrelas (bloco pequeno)
                      _ShimmerShape(
                        animation: animation,
                        width: 80,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  // Texto da Review (3 linhas simulando texto)
                  _ShimmerShape(
                    animation: animation,
                    width: double.infinity,
                    height: 10,
                    borderRadius: 2,
                  ),
                  const SizedBox(height: 6),
                  _ShimmerShape(
                    animation: animation,
                    width: double.infinity, // Linha cheia
                    height: 10,
                    borderRadius: 2,
                  ),
                  const SizedBox(height: 6),
                  _ShimmerShape(
                    animation: animation,
                    width: screenWidth * 0.3, // Linha curta para parecer final de parágrafo
                    height: 10,
                    borderRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget genérico que aplica a animação de shimmer em qualquer formato
class _ShimmerShape extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerShape({
    required this.animation,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos uma cor base levemente mais clara que o fundo do card
    // para destacar os elementos do esqueleto
    final baseColor = Colors.white.withOpacity(0.05);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor, 
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              children: [
                // Gradiente animado
                Positioned(
                  left: animation.value * MediaQuery.of(context).size.width, 
                  // Ajustei o multiplicador acima para o gradiente passar mais rápido ou devagar dependendo da largura
                  right: -animation.value * MediaQuery.of(context).size.width,
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
              ],
            ),
          ),
        );
      },
    );
  }
}