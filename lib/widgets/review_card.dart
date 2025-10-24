import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:watchers/widgets/series_card.dart';

class ReviewCard extends StatefulWidget {
  final ReviewModel review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  late bool _isFavorited;
  bool _isExpanded = false;

  // Define um limite de caracteres para o texto "recolhido"
  static const int kCollapsedTextLimit = 150;

  @override
  void initState() {
    super.initState();
    // Inicializa o estado 'favoritado' com base no modelo
    _isFavorited = widget.review.liked;
  }

  @override
  Widget build(BuildContext context) {
    // Para simplificar, vamos assumir que as imagens de poster e avatar
    // podem ser nulas. Usamos um placeholder se forem.
    final String posterUrl = widget.review.series.posterUrl;
    final String? avatarUrl = widget.review.author.avatarUrl;

    // Define a cor de fundo do card
    final cardColor = Colors.grey[900];

    // Define o raio da borda
    const double cardRadius = 12.0;

    return Card(
      elevation: 4.0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      clipBehavior:
          Clip.antiAlias, // Garante que o conteúdo interno respeite as bordas
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: sizePadding,
          children: [
            // --- 1. ClipRRect (para a Imagem) ---
            SizedBox(
              width: 80,
              height: 118,
              child: SeriesCard(
                series: widget.review.series,
                isSelected: false,
                onTap: () {}, // Substituir: Levar à tela da série!
              ),
            ),
        
            // --- 2. Expanded (para as Informações) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Text (Título) ---
                  Text(
                    widget.review.series.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                      
                  // --- Container (Badge "Temporada 1") ---
                  // Só mostra o badge se a informação existir
                  if (widget.review.reviewed != null &&
                      widget.review.reviewed!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[700],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.review.reviewed!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                      
                  // --- Row (Avaliação) ---
                  Row(
                    children: [
                      // --- Row (Usuário) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[700],
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.review.author.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // Helper para construir as estrelas
                      ..._buildStarRating(widget.review.stars),
                      Icon(
                        _isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorited ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                      
                  const SizedBox(height: 10),
                      
                  // --- Text.rich (Review "Lorem ipsum...") ---
                  _buildReviewText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper para construir a lista de ícones de estrela
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    // O rating da imagem é de 4/5 estrelas.
    // Este código converte um double (ex: 4.5) em estrelas cheias,
    // meias-estrelas e vazias.
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      } else {
        iconData = Icons.star_border;
      }
      stars.add(Icon(iconData, color: Colors.amber, size: 16));
    }
    return stars;
  }

  /// Helper para construir o texto expansível da review
  Widget _buildReviewText() {
    final String text = widget.review.content;
    final bool isTextLong = text.length > kCollapsedTextLimit;

    // Estilo do link "ler mais..."
    final linkStyle = TextStyle(
      color: Colors.blue[400],
      fontWeight: FontWeight.bold,
    );

    // Se o texto não for longo ou se já estiver expandido, mostre tudo
    if (!isTextLong || _isExpanded) {
      return Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white70, height: 1.4),
          children: [
            // Adiciona "ler menos" se for longo
            if (isTextLong)
              TextSpan(
                text: " Ler menos",
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
              ),
          ],
        ),
      );
    }

    // Se o texto for longo e NÃO estiver expandido, mostre o trecho
    return Text.rich(
      TextSpan(
        text: text.substring(0, kCollapsedTextLimit), // Pega só o início
        style: const TextStyle(color: Colors.white70, height: 1.4),
        children: [
          TextSpan(text: "..."),
          TextSpan(
            text: " Ler mais",
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                setState(() {
                  _isExpanded = true;
                });
              },
          ),
        ],
      ),
    );
  }
}
