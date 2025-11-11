import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/theme/colors.dart';

class SeriesCard extends StatelessWidget {
  final SerieModel series;
  final bool isSelected;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback onTap; // Função que deve ser chamada quando a série for selecionada

  const SeriesCard({
    super.key,
    required this.series,
    required this.isSelected,
    required this.onTap,
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            if (isSelected) Container(color: Colors.black.withAlpha(128)),

            if (isSelected)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Verifica se a URL é válida
    if (series.posterUrl != null && (series.posterUrl!.isEmpty || !_isValidUrl(series.posterUrl!))) {
      return Container(
        color: bColorPrimary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(series.name, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: series.posterUrl!,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) {
        return Container(
          color: bColorPrimary,
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          color: bColorPrimary,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Shimmer effect de fundo
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bColorPrimary,
                      bColorPrimary.withOpacity(0.7),
                      bColorPrimary,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Indicador de progresso moderno
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular progress com estilo moderno
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorPrimary.withOpacity(0.8),
                        ),
                      ),
                    ),
                    if (downloadProgress.progress != null) ...[
                      const SizedBox(height: 12),
                      // Percentual de carregamento
                      Text(
                        '${(downloadProgress.progress! * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}
