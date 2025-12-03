import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/theme/colors.dart';

class ImageCard extends StatelessWidget {
  final String? url;
  final String? fallbackText;
  final BorderRadiusGeometry? borderRadius;
  final Animation<double>? animation;
  final VoidCallback onTap; // Função que deve ser chamada quando a série for selecionada

  const ImageCard({
    super.key,
    required this.url,
    required this.onTap,
    this.fallbackText,
    this.borderRadius,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation ?? AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(),
              ],
            ),
          );        
        }
      ),
    );
  }

  Widget _buildImage() {
    // Verifica se a URL é válida
    if (url == null || (url!.isEmpty || !_isValidUrl(url!))) {
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
                size: 24,
              ),
              if (fallbackText != null) const SizedBox(height: 8),
              if (fallbackText != null)
                Text(fallbackText ?? '', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) {
        print(error);
        return Container(
          color: bColorPrimary,
          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
        );
      },
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          color: bColorPrimary,
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
              if (animation != null)
                Positioned(
                  left: animation!.value * MediaQuery.of(context).size.width * 0.25,
                  right: -animation!.value * MediaQuery.of(context).size.width * 0.25,
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
                child: animation != null ? Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: Colors.white.withOpacity(0.2),
                ) : CircularProgressIndicator(),
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
