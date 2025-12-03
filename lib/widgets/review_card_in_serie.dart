import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/theme/colors.dart';

class ReviewCardInSerie extends StatefulWidget {
  final ReviewModel review;

  const ReviewCardInSerie({Key? key, required this.review}) : super(key: key);

  @override
  _ReviewCardInSerieState createState() => _ReviewCardInSerieState();
}

class _ReviewCardInSerieState extends State<ReviewCardInSerie> {
  late bool _isFavorited;
  bool _isExpanded = false;

  static const int kCollapsedTextLimit = 150;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.review.liked;
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = widget.review.author.avatarUrl;
    
    // Cor de fundo escura conforme a imagem (quase preto)
    final cardColor = Color(0xFF1F1F1F); 

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0), // Bordas mais arredondadas conforme a foto
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding interno geral
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min, // Ocupa apenas o tamanho necessário
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. CABEÇALHO (Avatar, Nome, Estrelas, Like) ---
            Row(
              spacing: 12,
              children: [
                // Avatar (Maior que no design anterior)
                CircleAvatar(
                  radius: 20, 
                  backgroundColor: Colors.grey[800],
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),

                // Nome do Usuário
                Expanded(
                  child: Text(
                    widget.review.author.fullName != null && widget.review.author.fullName!.isNotEmpty ? widget.review.author.fullName! : "@${widget.review.author.username}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Fonte um pouco mais leve/moderna
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Estrelas
                if (widget.review.stars != null)
                Row(
                  children: _buildStarRating(widget.review.stars!),
                ),

                // Ícone de Coração
                Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? const Color(0xFFCC4A4A) : Colors.grey[600],
                  size: 20,
                ),
              ],
            ),

            // --- 2. TEXTO DA REVIEW ---
            // Reutilizando sua lógica que já estava ótima
            if (widget.review.content != null) _buildReviewText(),
          ],
        ),
      ),
    );
  }

  /// Helper para construir a lista de ícones de estrela
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      } else {
        iconData = Icons.star_border;
      }
      // Ajustei levemente o tamanho e cor para bater com a imagem 'violet'
      stars.add(Icon(iconData, color: Colors.amber, size: 18));
    }
    return stars;
  }

  /// Helper para construir o texto expansível da review
  Widget _buildReviewText() {
    final String text = widget.review.content ?? "";
    final bool isTextLong = text.length > kCollapsedTextLimit;

    // Estilo do link "ler mais..." (Azul da imagem)
    final linkStyle = TextStyle(
      color: Colors.blue[600], // Ajustado para o azul da imagem
      fontWeight: FontWeight.bold,
    );
    
    // Estilo do corpo do texto
    final bodyStyle = const TextStyle(
      color: Color(0xFFE0E0E0), // Branco levemente cinza para leitura
      height: 1.4,
      fontSize: 14,
    );

    if (!isTextLong || _isExpanded) {
      return Text.rich(
        TextSpan(
          text: text,
          style: bodyStyle,
          children: [
            if (isTextLong)
              TextSpan(
                text: " ler menos",
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

    return Text.rich(
      TextSpan(
        text: text.substring(0, kCollapsedTextLimit),
        style: bodyStyle,
        children: [
          const TextSpan(text: "... "), // Espaço antes do ler mais
          TextSpan(
            text: "ler mais",
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