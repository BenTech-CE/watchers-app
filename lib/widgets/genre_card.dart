import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:watchers/core/models/series/genre_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/theme/colors.dart';

class GenreCard extends StatelessWidget {
  final GenreModel genre;
  final VoidCallback
  onTap; // Função que deve ser chamada quando a série for selecionada

  const GenreCard({super.key, required this.genre, required this.onTap});

  Color lighten(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: genre.color.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Iconify(
                    genre.icon,
                    size: 40,
                    color: lighten(genre.color, 0.15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            genre.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tColorGray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
