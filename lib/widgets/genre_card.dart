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

  const GenreCard({
    super.key,
    required this.genre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: genre.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: SvgPicture.string(
            genre.icon,
            width: 48,
            height: 48,
          ),
        ),
      ),
    );
  }
}
