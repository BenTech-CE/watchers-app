import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cil.dart';
import 'package:iconify_flutter/icons/majesticons.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:iconify_flutter/icons/oi.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/star_rating.dart';

class ReviewAddPage extends StatefulWidget {
  const ReviewAddPage({super.key});

  @override
  State<ReviewAddPage> createState() => _ReviewAddPageState();
}

class _ReviewAddPageState extends State<ReviewAddPage> {
  String id = "";
  String title = "";
  String scope = "";
  String? posterPath;
  String? logoPath;
  int? seasonNumber;
  int? episodeNumber;
  double rating = 0;
  bool liked = false;

  final _reviewController = TextEditingController();

  void updateProviderState({
    bool? newLiked,
    double? newStars,
    int? newReviewId,
    String? newReviewText,
  }) {
    final userProvider = context.read<UserProvider>();
    final current = userProvider.currentUserInteractionData(scope);

    userProvider.setCurrentUserInteractionData(
      scope,
      UserInteractionData(
        isWatched: current.isWatched, // Usa o novo ou o local atual
        isLiked: newLiked ?? liked,
        inWatchlist: current.inWatchlist,
        stars:
            newStars ??
            (rating != 0
                ? rating
                : current.stars), // Ajuste conforme sua var rating
        reviewId: newReviewId ?? current.reviewId,
        reviewText: newReviewText ?? current.reviewText,
      ),
    );
  }

  void changeReview(bool? newLiked, double? newRating) async {
    final userProvider = context.read<UserProvider>();

    // 1. Guarda o valor antigo para Rollback
    final previousRating = rating;

    // Usa o helper criado na resposta anterior para propagar a mudança
    updateProviderState(newStars: newRating, newLiked: newLiked);

    // 3. Monta o objeto Review preservando os outros dados (like, texto)
    ReviewModel review = ReviewModel(
      id: null, // Mantém ID se existir
      stars: newRating, // O valor novo
      content: _reviewController.text.isNotEmpty
          ? _reviewController.text
          : null, // Texto da resenha ou null
      liked: liked, // Mantém o status de like atual
      series: ReviewSeries(id: 0, name: ''), // Boilerplate
      author: ReviewAuthor(id: '', username: ''), // Boilerplate
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    try {
      // 4. Chama a API
      final savedReview = await userProvider.saveReviewSeries(review, id);

      if (userProvider.errorMessage != null) {
        throw Exception(userProvider.errorMessage);
      }

      // 5. Sucesso: Atualiza o Provider com o retorno da API
      // Isso é crucial caso seja a primeira avaliação e um novo ID tenha sido gerado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resenha salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();

        updateProviderState(
          newStars: savedReview.stars,
          newReviewId: savedReview.id,
        );
      }
    } catch (e) {
      // 6. Rollback: Deu erro? Volta tudo como era antes.
      if (mounted) {
        setState(() {
          rating = previousRating;
        });
        updateProviderState(newStars: previousRating);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar resenha: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Inicializa o estado com base nos dados da série
    WidgetsBinding.instance.addPostFrameCallback((_){
      final userProvider = context.read<UserProvider>();

      final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      setState(() {
        title = args['title'];
        id = args['id'];
        _reviewController.text = args['content'] ?? "";
        scope = args['scope'];
        posterPath = args['posterPath'];
        logoPath = args['logoPath'];
        seasonNumber = args['seasonNumber'];
        episodeNumber = args['episodeNumber'];

        liked = userProvider.currentUserInteractionData(scope).isLiked;
        rating = (userProvider.currentUserInteractionData(scope).stars ?? 0)
            .toDouble();        
      });

    });
  }

  void changeRating(double newRating) {
    setState(() {
      rating = newRating;
    });
  }

  void changeLiked() {
    setState(() {
      liked = !liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // variaveis para o taman ho do poster (25% da tela, proporção 2:3)
    const double cardWidthFraction = 0.25;
    const double aspectRatio = 2 / 3;
    final double cardWidth =
        MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    final willShowLogo = logoPath != null && 
        logoPath!.isNotEmpty && 
        !logoPath!.toLowerCase().endsWith('.svg');

    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Faça sua resenha", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 16,
          children: [
            Row(
              spacing: 16,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: posterPath != null && posterPath!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: posterPath!,
                          width: cardWidth,
                          height: cardHeight,
                          errorWidget: (context, url, error) => Container(
                            width: cardWidth,
                            height: cardHeight,
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: cardWidth,
                          height: cardHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.movie, color: Colors.grey),
                        ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      height: cardHeight - 8,
                      child: Column(
                        spacing: 4,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          if (willShowLogo)
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 70,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: logoPath!,
                                height: 70,
                                width: double.infinity,
                                alignment:
                                    Alignment.centerLeft,
                                errorWidget: (context, url, error) => const SizedBox.shrink(),
                              ),
                            ),
                          if (!willShowLogo)
                            Text(
                              title,
                              style: AppTextStyles.titleLarge
                                  .copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                          Text(
                            "Você está resenhando ${scope == 'series' ? 'a Série.' : scope == 'season' ? 'a Temporada $seasonNumber.' : 'o Episódio $episodeNumber.'}",
                            style: AppTextStyles.bodyMedium
                                .copyWith(
                                  color: Color(0xff747474),
                                ),
                          ),
                          const Spacer(),
                          // Star Rating
                          Row(
                            children: [
                              StarRating(
                                rating: rating,
                                onRatingChanged: changeRating,
                                size: 32,
                                spacing: 6,
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: changeLiked,
                                child: Iconify(
                                  Mdi.heart,
                                  color: liked
                                      ? Color(0xFFCC4A4A)
                                      : Color(0xFF8D8D8D),
                                  size: 32,
                                ),
                              ),
                            ]
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Campo de texto para a resenha
            Expanded(
              child: TextField(
                controller: _reviewController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                expands: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F0F0F),
                  hintText: 'Escreva sua resenha...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 0,
            top: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.secondary,
                  label: "Descartar",
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: Button(
                  label: "Publicar",
                  onPressed: () {
                    changeReview(liked, rating);
                  },
                  disabled: userProvider.isLoadingUser,
                  loading: userProvider.isLoadingUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}