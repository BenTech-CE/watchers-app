import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:watchers/core/models/series/genre_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/theme/colors.dart';

class GenreCard extends StatelessWidget {
  final GenreModel genre;
  final Animation<double>? animation;
  final VoidCallback
  onTap; // Função que deve ser chamada quando a série for selecionada

  const GenreCard({
    super.key,
    required this.genre,
    this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation ?? AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  child: Iconify(genre.icon, size: 30),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
