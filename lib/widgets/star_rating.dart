// Widget de Star Rating reutilizável com suporte a meias estrelas
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double size;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfRating;
  final bool readOnly;

  const StarRating({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.size = 40,
    this.spacing = 4,
    this.activeColor = const Color(0xFFFFCC00),
    this.inactiveColor = const Color(0xFF8D8D8D),
    this.allowHalfRating = true,
    this.readOnly = false,
  });

  static const String _starSvg = '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><path fill="currentColor" d="M394 480a16 16 0 0 1-9.39-3L256 383.76L127.39 477a16 16 0 0 1-24.55-18.08L153 310.35L23 221.2a16 16 0 0 1 9-29.2h160.38l48.4-148.95a16 16 0 0 1 30.44 0l48.4 149H480a16 16 0 0 1 9.05 29.2L359 310.35l50.13 148.53A16 16 0 0 1 394 480"/></svg>';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final halfValue = starNumber - 0.5;
        final fullValue = starNumber.toDouble();

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Estrela de fundo (vazia)
              Iconify(
                _starSvg,
                color: inactiveColor,
                size: size,
              ),
              // Meia estrela (ativa) - clipa metade esquerda
              if (rating >= halfValue && rating < fullValue)
                ClipRect(
                  clipper: _HalfClipper(isLeft: true),
                  child: Iconify(
                    _starSvg,
                    color: activeColor,
                    size: size,
                  ),
                ),
              // Estrela cheia (ativa)
              if (rating >= fullValue)
                Iconify(
                  _starSvg,
                  color: activeColor,
                  size: size,
                ),
              // Áreas de toque (metade esquerda e direita)
              if (!readOnly && onRatingChanged != null)
                Row(
                  children: [
                    // Metade esquerda - meia estrela
                    Expanded(
                      child: GestureDetector(
                        onTap: allowHalfRating
                            ? () => onRatingChanged!(halfValue)
                            : () => onRatingChanged!(fullValue),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    // Metade direita - estrela cheia
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onRatingChanged!(fullValue),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }
}

// Clipper para cortar a estrela pela metade
class _HalfClipper extends CustomClipper<Rect> {
  final bool isLeft;

  _HalfClipper({required this.isLeft});

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTWH(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
    }
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) => oldClipper.isLeft != isLeft;
}